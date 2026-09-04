import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get h1 => GoogleFonts.poppins(
      fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get title => GoogleFonts.poppins(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get subtitle => GoogleFonts.poppins(
      fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static TextStyle get body => GoogleFonts.poppins(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get caption => GoogleFonts.poppins(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get button => GoogleFonts.poppins(
      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get navLabel => GoogleFonts.poppins(
      fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textTertiary);
}