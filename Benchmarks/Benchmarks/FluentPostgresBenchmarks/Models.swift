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

/// A hand-written approximation of the access code a future model macro could
/// generate. It deliberately maps to the same table as `NarrowModel` so the two
/// benchmark paths differ only in model materialization.
final class DirectNarrowModel: Model, @unchecked Sendable {
    static let schema = NarrowModel.schema
    static let space: String? = BenchmarkSchema.name

    @ID(custom: .id, generatedBy: .user) var id: Int?
    @Field(key: "name") var name: String
    @Field(key: "score") var score: Int

    init() {}

    var properties: [any AnyProperty] {
        [self.$id, self.$name, self.$score]
    }

    func input(to input: any DatabaseInput) {
        self.$id.input(to: input)
        self.$name.input(to: input)
        self.$score.input(to: input)
    }

    func output(from output: any DatabaseOutput) throws {
        try self.$id.output(from: output)
        try self.$name.output(from: output)
        try self.$score.output(from: output)
    }
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

/// Generated-style equivalent of `WideModel`. Keeping this implementation
/// intentionally repetitive makes the prospective macro's output and its cost
/// explicit: there is no reflection, intermediate property array, or existential
/// filtering on the database input/output path.
final class DirectWideModel: Model, @unchecked Sendable {
    static let schema = WideModel.schema
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

    var properties: [any AnyProperty] {
        [
            self.$id,
            self.$string1, self.$string2, self.$string3, self.$string4,
            self.$string5, self.$string6, self.$string7, self.$string8,
            self.$int1, self.$int2, self.$int3, self.$int4,
            self.$int5, self.$int6, self.$int7, self.$int8,
            self.$bool1, self.$bool2, self.$double1, self.$double2,
        ]
    }

    func input(to input: any DatabaseInput) {
        self.$id.input(to: input)
        self.$string1.input(to: input)
        self.$string2.input(to: input)
        self.$string3.input(to: input)
        self.$string4.input(to: input)
        self.$string5.input(to: input)
        self.$string6.input(to: input)
        self.$string7.input(to: input)
        self.$string8.input(to: input)
        self.$int1.input(to: input)
        self.$int2.input(to: input)
        self.$int3.input(to: input)
        self.$int4.input(to: input)
        self.$int5.input(to: input)
        self.$int6.input(to: input)
        self.$int7.input(to: input)
        self.$int8.input(to: input)
        self.$bool1.input(to: input)
        self.$bool2.input(to: input)
        self.$double1.input(to: input)
        self.$double2.input(to: input)
    }

    func output(from output: any DatabaseOutput) throws {
        try self.$id.output(from: output)
        try self.$string1.output(from: output)
        try self.$string2.output(from: output)
        try self.$string3.output(from: output)
        try self.$string4.output(from: output)
        try self.$string5.output(from: output)
        try self.$string6.output(from: output)
        try self.$string7.output(from: output)
        try self.$string8.output(from: output)
        try self.$int1.output(from: output)
        try self.$int2.output(from: output)
        try self.$int3.output(from: output)
        try self.$int4.output(from: output)
        try self.$int5.output(from: output)
        try self.$int6.output(from: output)
        try self.$int7.output(from: output)
        try self.$int8.output(from: output)
        try self.$bool1.output(from: output)
        try self.$bool2.output(from: output)
        try self.$double1.output(from: output)
        try self.$double2.output(from: output)
    }
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
