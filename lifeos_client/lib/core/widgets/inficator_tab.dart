// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';

class IndicatorTab extends StatelessWidget {
  const IndicatorTab({
    Key? key,
    required this.onTap,
    required this.title,
    required this.color,
    required this.number,
    this.isScrolable = false,
  }) : super(key: key);

  final Function() onTap;
  final String title;
  final bool isScrolable;
  final Color color;
  final int number;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isScrolable ? null : double.infinity,
      child: Tappable(
        onTap: onTap,
        child: Tab(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    number.toString(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                isScrolable
                    ? Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
