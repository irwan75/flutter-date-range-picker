import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/date_picker_with_periode.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_date_range_picker/widgets/wrap_text_button.dart';

void main() {
  return runApp(const MyApp());
}

/// My app class to display the date range picker
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

/// State for MyApp
class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Sample Date Picker",
      home: SampleDatePicker(),
    );
  }
}

class SampleDatePicker extends StatefulWidget {
  const SampleDatePicker({Key? key}) : super(key: key);

  @override
  State<SampleDatePicker> createState() => _SampleDatePickerState();
}

class _SampleDatePickerState extends State<SampleDatePicker> {
  DateTime? startDateSelected, endDateSelected;

  final LayerLink _layerLink = LayerLink();

  OverlayState? overlayState;
  OverlayEntry? overlayEntry;

  _shwoOverlay(BuildContext context){
    overlayState = Overlay.of(context);

    overlayEntry = OverlayEntry(builder: (contect){
      return Positioned(
        width: 500,
        height: 350,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            child: DatePickerWithPeriode(
              setDateActionCallback: ({startDate, endDate}) {
                setState(() {
                  startDateSelected = startDate;
                  endDateSelected = endDate;
                });
              },
            ),
          ),
        ),
      );

    });

    overlayState!.insert(overlayEntry!);

  }

  void _hideOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sample Date Picker")),
      body: InkWell(
        onTap: _hideOverlay,
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CompositedTransformTarget(
                  link: _layerLink,
                  child: WrapTextButton('Show date picker multiple view',
                      height: 50,
                      backgroundColor: Colors.blue,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16), onTap: () {
                            _shwoOverlay(context);
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  'Start date: ${startDateSelected != null ? DateFormat('dd/MM/yyyy').format(startDateSelected!) : ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'End date: ${endDateSelected != null ? DateFormat('dd/MM/yyyy').format(endDateSelected!) : ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16),
                )
              ]),
        ),
      ),
    );
  }
}
