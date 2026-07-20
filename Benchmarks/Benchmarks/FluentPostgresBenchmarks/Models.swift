import FluentKit

enum BenchmarkSchema {
    static let name = "fluentkit_benchmark"
}

final class NarrowModel: Model, @unchecked Sendable {
    static let schema = "narrow_models"
    static let space: String? = BenchmarkSchema.name

    @ID(custom: .id, generatedBy: .user) var id: Int?
    @Field(key: "name") var name: String
    @Field(key: "score") var score: Int

    init() {}
}

final class WideModel: Model, @unchecked Sendable {
    static let schema = "wide_models"
    static let space: String? = BenchmarkSchema.name

    @ID(custom: .id, generatedBy: .user) var id: Int?
    @Field(key: "string_1") var string1: String
    @Field(key: "string_2") var string2: String
    @Field(key: "string_3") var string3: String
    @Field(key: "string_4") var string4: String
    @Field(key: "string_5") var string5: String
    @Field(key: "string_6") var string6: String
    @Field(key: "string_7") var string7: String
    @Field(key: "string_8") var string8: String
    @Field(key: "int_1") var int1: Int
    @Field(key: "int_2") var int2: Int
    @Field(key: "int_3") var int3: Int
    @Field(key: "int_4") var int4: Int
    @Field(key: "int_5") var int5: Int
    @Field(key: "int_6") var int6: Int
    @Field(key: "int_7") var int7: Int
    @Field(key: "int_8") var int8: Int
    @Field(key: "bool_1") var bool1: Bool
    @Field(key: "bool_2") var bool2: Bool
    @Field(key: "double_1") var double1: Double
    @Field(key: "double_2") var double2: Double

    init() {}
}

final class ParentModel: Model, @unchecked Sendable {
    static let schema = "parent_models"
    static let space: String? = BenchmarkSchema.name

    @ID(custom: .id, generatedBy: .user) var id: Int?
    @Field(key: "name") var name: String
    @Children(for: \.$parent) var children: [ChildModel]

    init() {}
}

final class ChildModel: Model, @unchecked Sendable {
    static let schema = "child_models"
    static let space: String? = BenchmarkSchema.name

    @ID(custom: .id, generatedBy: .user) var id: Int?
    @Parent(key: "parent_id") var parent: ParentModel
    @Field(key: "name") var name: String
    @Field(key: "payload") var payload: String

    init() {}
}
