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
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _values = _parseLevel(widget.initialValue!);
    } else {
      _values = const RangeValues(3, 3);
    }
  }

  RangeValues _parseLevel(String level) {
    final parts = level.split(' ');
    if (parts.length < 2) return const RangeValues(9, 9);

    String strengthStr = parts[0].toLowerCase();
    String levelStr = parts.sublist(1).join(' ').toLowerCase();

    int strengthIndex = strengths.indexWhere((s) => s.toLowerCase() == strengthStr);
    int levelIndex = levels.indexWhere((l) => l.toLowerCase() == levelStr);

    if (strengthIndex == -1 || levelIndex == -1) return const RangeValues(9, 9);

    double position = (levelIndex * strengths.length + strengthIndex).toDouble();
    return RangeValues(position, position);
  }

  String _getLabel(double value) {
    int positionIndex = value.round();
    int levelIndex = positionIndex ~/ strengths.length;
    int strengthIndex = positionIndex % strengths.length;
    
    if (levelIndex >= levels.length) levelIndex = levels.length - 1;
    if (strengthIndex >= strengths.length) strengthIndex = strengths.length - 1;
    
    return "${strengths[strengthIndex]} ${levels[levelIndex]}";
  }

  @override
  Widget build(BuildContext context) {
    if (_values == null) {
      return const SizedBox.shrink();
    }

    int totalDivisions = (levels.length * strengths.length) - 1;

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
              setState(() {
                _values = val;
                String startLabel = _getLabel(_values!.start);
                String endLabel = _getLabel(_values!.end);
                String updatedLabel = (_values!.start == _values!.end) 
                    ? startLabel 
                    : "$startLabel - $endLabel";
                widget.onChanged(updatedLabel);
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(levels.length, (levelIdx) {
            return Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(strengths.length, (strengthIdx) {
                      int positionIndex = levelIdx * strengths.length + strengthIdx;
                      
                      int startPos = _values!.start.round();
                      int endPos = _values!.end.round();
                      
                      bool isThumbHere = (positionIndex == startPos || positionIndex == endPos);
                      
                      return Text(
                        strengths[strengthIdx][0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isThumbHere ? Colors.blue : Colors.grey.shade400,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      levels[levelIdx],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
