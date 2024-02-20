import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/utils/colors_utils.dart';
import 'package:flutter_date_range_picker/utils/image_paths.dart';
import 'package:flutter_date_range_picker/widgets/text_field_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/date_formatter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'utils/typedef_collection.dart';
import 'widgets/wrap_text_button.dart';

class DatePickerWithPeriodeMobileView extends StatefulWidget {
  final SetDateActionCallback onTapApply;
  final DateTime? startDate;
  final DateTime? endDate;

  const DatePickerWithPeriodeMobileView({
    Key? key,
    required this.onTapApply,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  State<DatePickerWithPeriodeMobileView> createState() =>
      _DatePickerWithPeriodeMobileViewState();
}

class _DatePickerWithPeriodeMobileViewState
    extends State<DatePickerWithPeriodeMobileView> {
  final String dateTimePattern = 'dd/MM/yyyy';

  late DateRangePickerController _datePickerController;
  late TextEditingController _startDateInputController;
  late TextEditingController _endDateInputController;

  DateTime? _startDate, _endDate;
  late Debouncer _denounceStartDate, _denounceEndDate;

  // final ValueNotifier<bool> _switchPeriode = ValueNotifier<bool>(false);

  @override
  void initState() {
    _datePickerController = DateRangePickerController();
    _startDateInputController = TextEditingController();
    _endDateInputController = TextEditingController();
    _startDate = widget.startDate ?? DateTime.now();
    _endDate = widget.endDate ?? DateTime.now();
    // _switchPeriode.value = widget.isMultipleRange ?? false;
    _initDebounceTimeForDate();
    _updateDateTextInput();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: ColorsUtils.colorShadow,
              spreadRadius: 32,
              blurRadius: 32,
              offset: Offset.zero),
          BoxShadow(
              color: ColorsUtils.colorShadow,
              spreadRadius: 12,
              blurRadius: 12,
              offset: Offset.zero)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _sectionInputDate(context),
          ),
          SfDateRangePicker(
            controller: _datePickerController,
            onSelectionChanged: _onSelectionChanged,
            view: DateRangePickerView.month,
            selectionMode: DateRangePickerSelectionMode.range,
            initialDisplayDate: _startDate,
            initialSelectedDate: _startDate,
            initialSelectedRange: PickerDateRange(_startDate, _endDate),
            enableMultiView: true,
            enablePastDates: true,
            viewSpacing: 16,
            headerHeight: 52,
            backgroundColor: Colors.white,
            selectionShape: DateRangePickerSelectionShape.rectangle,
            showNavigationArrow: true,
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
                  color: Colors.white, borderRadius: BorderRadius.circular(6)),
              todayTextStyle: const TextStyle(
                  color: ColorsUtils.colorButton, fontWeight: FontWeight.bold),
              disabledDatesTextStyle: const TextStyle(
                  color: ColorsUtils.colorButton, fontWeight: FontWeight.bold),
            ),
            headerStyle: const DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold)),
          ),
          const VerticalDivider(color: ColorsUtils.colorDivider, width: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              WrapTextButton(
                'Cancel',
                maxWidth: 150,
                textStyle: const TextStyle(
                  color: ColorsUtils.colorButton,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                radius: 10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 4),
                backgroundColor: ColorsUtils.colorButtonDisable,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 15),
              WrapTextButton(
                'Apply',
                maxWidth: 150,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                radius: 10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 4),
                backgroundColor: ColorsUtils.colorButton,
                onTap: () {
                  if (_startDate != null && _endDate != null) {
                    widget.onTapApply(_startDate, _endDate);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionInputDate(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
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
          ),
        ),
        const SizedBox(width: 12),
        SvgPicture.asset(ImagePaths.icDateRange,
            package: ImagePaths.packageName),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
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
          ),
        ),
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
