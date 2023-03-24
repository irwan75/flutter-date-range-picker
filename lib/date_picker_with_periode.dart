import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/utils/colors_utils.dart';
import 'package:flutter_date_range_picker/utils/image_paths.dart';
import 'package:flutter_date_range_picker/widgets/text_field_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/date_formatter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

typedef SetDateActionCallback = Function(
    {DateTime? startDate, DateTime? endDate});

class DatePickerWithPeriode extends StatefulWidget {
  final SetDateActionCallback? setDateActionCallback;

  const DatePickerWithPeriode(
      {Key? key,
      this.setDateActionCallback})
      : super(key: key);

  @override
  State<DatePickerWithPeriode> createState() =>
      _DatePickerWithPeriodeState();
}

class _DatePickerWithPeriodeState
    extends State<DatePickerWithPeriode> {
  final String dateTimePattern = 'dd/MM/yyyy';

  late DateRangePickerController _datePickerController;
  late TextEditingController _startDateInputController;
  late TextEditingController _endDateInputController;

  DateTime? _startDate, _endDate;
  late Debouncer _denounceStartDate, _denounceEndDate;

  final ValueNotifier<bool> _switchPeriode = ValueNotifier<bool>(false);

  @override
  void initState() {
    _datePickerController = DateRangePickerController();
    _startDateInputController = TextEditingController();
    _endDateInputController =TextEditingController();
    _startDate = DateTime.now();
    _initDebounceTimeForDate();
    _updateDateTextInput();
    super.initState();
  }

  void _initDebounceTimeForDate() {
    _denounceStartDate = Debouncer<String>(const Duration(milliseconds: 300), initialValue: '');
    _denounceEndDate = Debouncer<String>(const Duration(milliseconds: 300), initialValue: '');

    _denounceStartDate.values.listen((value) => _onStartDateTextChanged(value));
    _denounceEndDate.values.listen((value) => _onEndDateTextChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _switchPeriode,
        builder: (context, value, widget) {
          return Container(
            width: value ? 500 : 250,
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
                ]),
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text('Periode', style: TextStyle(fontWeight: FontWeight.bold),),
                      const SizedBox(
                        width: 10,
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _switchPeriode,
                        builder: (context, state, widget) {
                          return Switch(
                              value: state,
                              onChanged: (value) {
                                _switchPeriode.value = value;
                              });
                        },
                      )
                    ],
                  )),
              Padding(
                padding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: _sectionInputDate(context),
              ),
              Expanded(
                child: Stack(children: [
                  Positioned.fill(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SfDateRangePicker(
                      controller: _datePickerController,
                      onSelectionChanged: _onSelectionChanged,
                      view: DateRangePickerView.month,
                      selectionMode: value
                          ? DateRangePickerSelectionMode.range
                          : DateRangePickerSelectionMode.single,
                      initialDisplayDate: _startDate,
                      initialSelectedRange: PickerDateRange(_startDate, _endDate),
                      enableMultiView: value,
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
                              fontWeight: FontWeight.bold)),
                    ),
                  )),
                  const Center(
                      child:
                          VerticalDivider(color: ColorsUtils.colorDivider, width: 1)),
                ]),
              ),
            ]),
          );
        }
      );
  }

  Widget _sectionInputDate(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _switchPeriode,
      builder: (context, value, child) {
        return value ? Row(
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
        ]) : SizedBox(
          width: double.infinity,
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
        );
      },
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

    if(_startDate != null && _endDate != null) widget.setDateActionCallback!(startDate: _startDate, endDate: _endDate);

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
