import 'package:flutter/material.dart';

// Purpose: Provide a reusable text widget with consistent styling
// Responsibilities: Display text with customizable style properties
// Why this class exists: To create a reusable text component for consistent UI

class CustomText extends StatelessWidget {
  // The text to display
  final String text;
  
  // Font size of the text
  final double? fontSize;
  
  // Font weight of the text
  final FontWeight? fontWeight;
  
  // Color of the text
  final Color? color;
  
  // Text alignment
  final TextAlign? textAlign;
  
  // Maximum number of lines
  final int? maxLines;
  
  // How to handle overflow
  final TextOverflow? overflow;

  // Constructor for CustomText
  // Inputs: Text string and optional styling parameters
  // Why this exists: To create a text widget with flexible styling options
  const CustomText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
