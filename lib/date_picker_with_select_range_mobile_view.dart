import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/utils/colors_utils.dart';
import 'package:flutter_date_range_picker/widgets/text_field_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/date_formatter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'utils/image_paths.dart';
import 'utils/typedef_collection.dart';
import 'widgets/base_card_selected_category_filter.dart';

class DatePickerWithSelectRangeMobileView extends StatefulWidget {
  final SetRangeActionCallbackMode? setDateActionCallback;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isMultipleRange;
  final int? initialModeView;
  final DateRangePickerView? view;
  final ValueNotifier<DateRangePickerView?>? changed;

  const DatePickerWithSelectRangeMobileView(
      {Key? key,
      this.setDateActionCallback,
      this.startDate,
      this.endDate,
      this.isMultipleRange,
      this.initialModeView,
      this.view,
      this.changed})
      : super(key: key);

  @override
  State<DatePickerWithSelectRangeMobileView> createState() =>
      _DatePickerWithPeriodeState();
}

const List<String> list = <String>['Tahun', 'Bulan', 'Custom'];

class _DatePickerWithPeriodeState
    extends State<DatePickerWithSelectRangeMobileView> {
  final String dateTimePattern = 'dd/MM/yyyy';

  late DateRangePickerController _datePickerController;
  late TextEditingController _startDateInputController;
  late TextEditingController _endDateInputController;

  DateTime? _startDate, _endDate;
  late Debouncer _denounceStartDate, _denounceEndDate;

  ValueNotifier<DateRangePickerView?> pickerView =
      ValueNotifier<DateRangePickerView?>(null);
  ValueNotifier<int?> modeView = ValueNotifier<int?>(null);

  ValueNotifier<String> dropdownValue = ValueNotifier<String>(list[2]);

  @override
  void initState() {
    _datePickerController = DateRangePickerController();
    _startDateInputController = TextEditingController();
    _endDateInputController = TextEditingController();
    _startDate = widget.startDate ?? DateTime.now();
    _endDate = widget.endDate ?? DateTime.now();
    _initDebounceTimeForDate();
    _updateDateTextInput();
    _initModeView();
    super.initState();
  }

  void _initDebounceTimeForDate() {
    _denounceStartDate =
        Debouncer<String>(const Duration(milliseconds: 300), initialValue: '');
    _denounceEndDate =
        Debouncer<String>(const Duration(milliseconds: 300), initialValue: '');

    _denounceStartDate.values.listen((value) => _onStartDateTextChanged(value));
    _denounceEndDate.values.listen((value) => _onEndDateTextChanged(value));
  }

  _initModeView() {
    modeView.value = widget.initialModeView;
    if (modeView.value != null) {
      switch (modeView.value) {
        case 1:
          _datePickerController.view = DateRangePickerView.decade;
          break;
        case 2:
          _datePickerController.view = DateRangePickerView.year;
          break;
        case 3:
          _datePickerController.view = DateRangePickerView.month;
          break;
        default:
          _datePickerController.view = DateRangePickerView.month;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: modeView,
        builder: (context, modes, widget) {
          return StatefulBuilder(builder: (context, innerState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 1,
                      child: BaseCardSelectedCategoryFilter(
                        selectedMode: modes,
                        valueMode: 1,
                        title: 'Tahunan',
                        onTap: () {
                          if (modes == null || modes != 1) {
                            modeView.value = 1;
                            pickerView.value = DateRangePickerView.decade;
                            _datePickerController.view =
                                DateRangePickerView.decade;
                          } else {
                            modeView.value = null;
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: BaseCardSelectedCategoryFilter(
                        selectedMode: modes,
                        valueMode: 2,
                        title: 'Bulanan',
                        onTap: () {
                          if (modes == null || modes != 2) {
                            modeView.value = 2;
                            pickerView.value = DateRangePickerView.year;
                            _datePickerController.view =
                                DateRangePickerView.year;
                          } else {
                            modeView.value = null;
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: BaseCardSelectedCategoryFilter(
                        selectedMode: modes,
                        valueMode: 3,
                        title: 'Custom',
                        onTap: () {
                          if (modes == null || modes != 3) {
                            modeView.value = 3;
                            pickerView.value = DateRangePickerView.month;
                            _datePickerController.view =
                                DateRangePickerView.month;
                          } else {
                            modeView.value = null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _sectionInputDate(context),
                const SizedBox(height: 16),
                ValueListenableBuilder<DateRangePickerView?>(
                  valueListenable: pickerView,
                  builder: (context, pickerViews, widget) {
                    return SfDateRangePicker(
                      controller: _datePickerController,
                      onSelectionChanged: _onSelectionChanged,
                      view: pickerViews ?? DateRangePickerView.month,
                      selectionMode: DateRangePickerSelectionMode.range,
                      initialDisplayDate: _startDate,
                      initialSelectedDate: _startDate,
                      initialSelectedRange:
                          PickerDateRange(_startDate, _endDate),
                      enableMultiView: true,
                      enablePastDates: true,
                      viewSpacing: 16,
                      headerHeight: 52,
                      backgroundColor: Colors.white,
                      selectionShape: DateRangePickerSelectionShape.rectangle,
                      showNavigationArrow: false,
                      allowViewNavigation: false,
                      selectionColor: ColorsUtils.colorButton,
                      startRangeSelectionColor: ColorsUtils.colorButton,
                      endRangeSelectionColor: ColorsUtils.colorButton,
                      selectionRadius: 6,
                      monthViewSettings: const DateRangePickerMonthViewSettings(
                          dayFormat: 'EE',
                          firstDayOfWeek: 1,
                          viewHeaderHeight: 48,
                          viewHeaderStyle: DateRangePickerViewHeaderStyle(
                              backgroundColor: Colors.white,
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      monthCellStyle: DateRangePickerMonthCellStyle(
                        cellDecoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        todayTextStyle: const TextStyle(
                            color: ColorsUtils.colorButton,
                            fontWeight: FontWeight.bold),
                        disabledDatesTextStyle: const TextStyle(
                            color: ColorsUtils.colorButton,
                            fontWeight: FontWeight.bold),
                      ),
                      headerStyle: const DateRangePickerHeaderStyle(
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                )
              ],
            );
          });
        });
  }

  Widget _sectionInputDate(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFieldBuilder(
            key: const Key('start_date_input'),
            textController: _startDateInputController,
            onTextChange: (value) {
              _denounceStartDate.value = value;
            },
            hintText: 'dd/mm/yyyy',
            keyboardType: TextInputType.number,
            inputFormatters: [
              DateInputFormatter(),
            ],
            borderRadius: 4,
          ),
        ),
        const SizedBox(height: 10),
        SvgPicture.asset(ImagePaths.icDateRange,
            package: ImagePaths.packageName),
        const SizedBox(height: 10),
        Expanded(
          child: TextFieldBuilder(
            key: const Key('end_date_input'),
            textController: _endDateInputController,
            onTextChange: (value) {
              _denounceEndDate.value = value;
            },
            hintText: 'dd/mm/yyyy',
            keyboardType: TextInputType.number,
            inputFormatters: [
              DateInputFormatter(),
            ],
            borderRadius: 4,
          ),
        )
      ],
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      _startDate = args.value.startDate;
      _endDate = args.value.endDate;
      _updateDateTextInput();
    } else {
      _startDate = args.value;
      _endDate = args.value;
      _updateDateTextInput();
    }
  }

  void _onStartDateTextChanged(String value) {
    if (value.isNotEmpty && !value.contains('-')) {
      final startDate = DateFormat(dateTimePattern).parse(value);
      _startDate = startDate;
      _updateDatePickerSelection();
    }
  }

  void _onEndDateTextChanged(String value) {
    if (value.isNotEmpty && !value.contains('-')) {
      final endDate = DateFormat(dateTimePattern).parse(value);
      _endDate = endDate;
      _updateDatePickerSelection();
    }
  }

  Future<void> _updateDatePickerSelection() async {
    _datePickerController.selectedRange = PickerDateRange(_startDate, _endDate);
    _datePickerController.displayDate = _startDate;
  }

  void _updateDateTextInput() {
    if (_startDate != null) {
      final startDateString = DateFormat(dateTimePattern).format(_startDate!);
      _startDateInputController.value = TextEditingValue(
          text: startDateString,
          selection: TextSelection(
              baseOffset: startDateString.length,
              extentOffset: startDateString.length));
    } else {
      _startDateInputController.clear();
    }
    if (_endDate != null) {
      final endDateString = DateFormat(dateTimePattern).format(_endDate!);
      _endDateInputController.value = TextEditingValue(
          text: endDateString,
          selection: TextSelection(
              baseOffset: endDateString.length,
              extentOffset: endDateString.length));
    } else {
      _endDateInputController.clear();
    }

    if (_startDate != null && _endDate != null) {
      widget.setDateActionCallback!(_startDate, _endDate, modeView.value);
    }
  }

  @override
  void dispose() {
    _denounceStartDate.cancel();
    _denounceEndDate.cancel();
    _startDateInputController.dispose();
    _endDateInputController.dispose();
    _datePickerController.dispose();
    super.dispose();
  }
}
