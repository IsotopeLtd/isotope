import 'package:isotope/src/utilities/camel_case_to_words.dart';

/// USAGE:
/// import 'package:enum_to_string/enum_to_string.dart';
/// enum TestEnum { testValue1, testValue2 };
/// convert(){
///     String result = EnumToString.parse(TestEnum.testValue1);
///     //result = 'testValue1'
///     String resultCamelCase = EnumToString.parseCamelCase(TestEnum.testValue1);
///     //result = 'Test Value 1'
///     final result = EnumToString.fromString(TestEnum.values, "testValue1");
///     // TestEnum.testValue1
///     EnumToString.toList(TestEnum.values);
///     //result = 'testValue1','testValue2',   
///     EnumToString.toList(TestEnum.values, camelCase: true);
///     //result = 'TestValue1','TestValue2',
/// }

class EnumToString {
  static String parse(enumItem, {bool camelCase = false}) {
    if (enumItem == null) return null;
    final _tmp = enumItem.toString().split('.')[1];
    return !camelCase ? _tmp : camelCaseToWords(_tmp);
  }

  static String parseCamelCase(enumItem) {
    if (enumItem == null) return null;
    final parsed = EnumToString.parse(enumItem);
    return camelCaseToWords(parsed);
  }

  static T fromString<T>(List<T> enumValues, String value) {
    if (value == null || enumValues == null) return null;

    return enumValues.singleWhere(
        (enumItem) =>
            EnumToString.parse(enumItem)?.toLowerCase() == value?.toLowerCase(),
        orElse: () => null);
  }

  static List<String> toList<T>(List<T> enumValues, {bool camelCase = false}) {
    if (enumValues == null) return null;
    final _enumList = enumValues
        .map((t) =>
            !camelCase ? EnumToString.parse(t) : EnumToString.parseCamelCase(t))
        .toList();
    return _enumList;
  }
}
