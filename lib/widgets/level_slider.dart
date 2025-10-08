import 'package:flutter/material.dart';

class LevelSlider extends StatefulWidget {
  final Function(String) onChanged;
  final String? initialValue;

  const LevelSlider({required this.onChanged, this.initialValue, Key? key})
      : super(key: key);

  @override
  State<LevelSlider> createState() => _LevelSliderState();
}

class _LevelSliderState extends State<LevelSlider> {
  final levels = [
    "Intermediate",
    "Level G",
    "Level F",
    "Level E",
    "Level D",
    "Open"
  ];
  final strengths = ["Weak", "Mid", "Strong"];

  RangeValues? _values;

  @override
  void initState() {
    super.initState();
    _values = const RangeValues(7, 10); 
  }

  String _getLabel(double value) {
    int index = value.round();
    int levelIndex = index ~/ 3;
    int strengthIndex = index % 3;
    return "${strengths[strengthIndex]} ${levels[levelIndex]}";
  }

  @override
  Widget build(BuildContext context) {
    if (_values == null) {
      return const SizedBox.shrink();
    }

    int totalDivisions = (levels.length * strengths.length) - 1;
    String startLabel = _getLabel(_values!.start);
    String endLabel = _getLabel(_values!.end);

   
    String displayLabel = "$startLabel, $endLabel";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbColor: Colors.blueAccent,
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.grey.shade300,
            overlayColor: Colors.blue.withOpacity(0.1),
            rangeThumbShape:
                const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: RangeSlider(
            values: _values!,
            divisions: totalDivisions,
            min: 0,
            max: totalDivisions.toDouble(),
            onChanged: (val) {
              setState(() => _values = val);
              widget.onChanged(displayLabel);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(levels.length, (i) {
            return Column(
              children: [
                Row(
                  children: strengths
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              s[0], 
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ))
                      .toList(),
                ),
                Text(levels[i],
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600)),
              ],
            );
          }),
        ),
      ],
    );
  }
}
