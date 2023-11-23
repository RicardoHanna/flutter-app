import 'package:flutter/material.dart';class RoundedIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const RoundedIcon({
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue, // You can change the color as needed
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 40,
          color: Colors.white, // You can change the color as needed
        ),
      ),
    );
  }
}

