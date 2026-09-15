import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';

class TwoContainersRow extends StatelessWidget {
  final Widget child1;
  final Widget child2;
  final double? height;

  const TwoContainersRow({Key? key, required this.child1, required this.child2, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            height: height == null ? 200 : height,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 80,
                vertical: MediaQuery.of(context).size.height / 120,
              ),
              child: child1,
            ),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width / 50),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              color: ColorManager.white,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            height: height == null ? 200 : height,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 80,
                vertical: MediaQuery.of(context).size.height / 120,
              ),
              child: child2,
            ),
          ),
        ),
      ],
    );
  }
}
