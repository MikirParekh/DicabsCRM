import 'package:dicabs/core/color.dart';
import 'package:flutter/material.dart';

class GlobalDropdown extends StatelessWidget {
  final String labelText;
  final bool isSelected;
  const GlobalDropdown({super.key,required this.labelText, this.isSelected=false,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        children: [
          Container(
            decoration: ShapeDecoration(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(50)
              ),
              color: DColor.primaryColor.withOpacity(0.09),
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 12, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(labelText,style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: isSelected ? Colors.black : Colors.grey),),
                  const Icon(Icons.keyboard_arrow_down_rounded)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
