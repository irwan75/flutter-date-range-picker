typedef SetDateActionCallback = void Function(
  DateTime? startDate,
  DateTime? endDate,
);

typedef SetDateActionCallbackMultipleRange = void Function(
  DateTime? startDate,
  DateTime? endDate,
  bool? isMultipleRange,
);

typedef SetRangeActionCallbackMode = void Function(
  DateTime? startDate,
  DateTime? endDate,
  int? mode,
);
