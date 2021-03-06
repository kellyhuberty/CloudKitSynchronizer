/// SQLQuery is a representation of an SQL query.
///
/// See SQLQueryGenerator for actual SQL generation.
struct SQLQuery {
    var relation: SQLRelation
    var isDistinct: Bool = false
    var groupPromise: DatabasePromise<[SQLExpression]>?
    // Having clause is an array of expressions that we'll join with
    // the AND operator. This gives nicer output in generated SQL:
    // `(a AND b AND c)` instead of `((a AND b) AND c)`.
    var havingExpressionsPromise: DatabasePromise<[SQLExpression]> = DatabasePromise(value: [])
    var limit: SQLLimit?
}

extension SQLQuery: Refinable {
    func distinct() -> Self {
        with(\.isDistinct, true)
    }
    
    func limit(_ limit: Int, offset: Int? = nil) -> Self {
        with(\.limit, SQLLimit(limit: limit, offset: offset))
    }
    
    func qualified(with alias: TableAlias) -> Self {
        // We do not need to qualify group and having clauses. They will be
        // in SQLQueryGenerator.init()
        map(\.relation) { $0.qualified(with: alias) }
    }
}

extension SQLQuery: SelectionRequest {
    func select(_ selection: @escaping (Database) throws -> [SQLSelectable]) -> Self {
        map(\.relation) { $0.select(selection) }
    }
    
    func annotated(with selection: @escaping (Database) throws -> [SQLSelectable]) -> Self {
        map(\.relation) { $0.annotated(with: selection) }
    }
}

extension SQLQuery: FilteredRequest {
    func filter(_ predicate: @escaping (Database) throws -> SQLExpressible) -> Self {
        map(\.relation) { $0.filter(predicate) }
    }
}

extension SQLQuery: OrderedRequest {
    func order(_ orderings: @escaping (Database) throws -> [SQLOrderingTerm]) -> Self {
        map(\.relation) { $0.order(orderings) }
    }
    
    func reversed() -> Self {
        map(\.relation) { $0.reversed() }
    }
    
    func unordered() -> Self {
        map(\.relation) { $0.unordered() }
    }
}

extension SQLQuery: AggregatingRequest {
    func group(_ expressions: @escaping (Database) throws -> [SQLExpressible]) -> Self {
        with(\.groupPromise, DatabasePromise { db in try expressions(db).map(\.sqlExpression) })
    }
    
    func having(_ predicate: @escaping (Database) throws -> SQLExpressible) -> Self {
        map(\.havingExpressionsPromise) { havingExpressionsPromise in
            DatabasePromise { db in
                try havingExpressionsPromise.resolve(db) + [predicate(db).sqlExpression]
            }
        }
    }
}

extension SQLQuery: _JoinableRequest {
    func _including(all association: _SQLAssociation) -> Self {
        map(\.relation) { $0._including(all: association) }
    }
    
    func _including(optional association: _SQLAssociation) -> Self {
        map(\.relation) { $0._including(optional: association) }
    }
    
    func _including(required association: _SQLAssociation) -> Self {
        map(\.relation) { $0._including(required: association) }
    }
    
    func _joining(optional association: _SQLAssociation) -> Self {
        map(\.relation) { $0._joining(optional: association) }
    }
    
    func _joining(required association: _SQLAssociation) -> Self {
        map(\.relation) { $0._joining(required: association) }
    }
}

extension SQLQuery {
    func fetchCount(_ db: Database) throws -> Int {
        try QueryInterfaceRequest<Int>(query: countQuery(db)).fetchOne(db)!
    }
    
    private func countQuery(_ db: Database) throws -> SQLQuery {
        guard groupPromise == nil && limit == nil else {
            // SELECT ... GROUP BY ...
            // SELECT ... LIMIT ...
            return trivialCountQuery
        }
        
        if relation.children.contains(where: { $0.value.impactsParentCount }) { // TODO: not tested
            // SELECT ... FROM ... JOIN ...
            return trivialCountQuery
        }
        
        guard case .table = relation.source else {
            // SELECT ... FROM (something which is not a plain table)
            return trivialCountQuery
        }
        
        let selection = try relation.selectionPromise.resolve(db)
        GRDBPrecondition(!selection.isEmpty, "Can't generate SQL with empty selection")
        if selection.count == 1 {
            guard let count = selection[0]._count(distinct: isDistinct) else {
                return trivialCountQuery
            }
            var countQuery = self.unordered()
            countQuery.isDistinct = false
            switch count {
            case .all:
                countQuery = countQuery.select(_SQLExpressionCount(AllColumns()))
            case .distinct(let expression):
                countQuery = countQuery.select(_SQLExpressionCountDistinct(expression))
            }
            return countQuery
        } else {
            // SELECT [DISTINCT] expr1, expr2, ... FROM tableName ...
            
            guard !isDistinct else {
                return trivialCountQuery
            }
            
            // SELECT expr1, expr2, ... FROM tableName ...
            // ->
            // SELECT COUNT(*) FROM tableName ...
            return self.unordered().select(_SQLExpressionCount(AllColumns()))
        }
    }
    
    // SELECT COUNT(*) FROM (self)
    private var trivialCountQuery: SQLQuery {
        let relation = SQLRelation(
            source: .subquery(unordered()),
            selectionPromise: DatabasePromise(value: [_SQLExpressionCount(AllColumns())]))
        return SQLQuery(relation: relation)
    }
}

struct SQLLimit {
    let limit: Int
    let offset: Int?
    
    var sql: String {
        if let offset = offset {
            return "\(limit) OFFSET \(offset)"
        } else {
            return "\(limit)"
        }
    }
}
