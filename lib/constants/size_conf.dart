import '../utils/size_config.dart';

class AppSizes {
  static double w5 = SizeConfig.blockWidth * 5;
  static double w10 = SizeConfig.blockWidth * 10; 
  static double w20 = SizeConfig.blockWidth * 20;
  static double w50 = SizeConfig.blockWidth * 50;
  static double h5 = SizeConfig.blockHeight * 5;
  static double h10 = SizeConfig.blockHeight * 10; 
  static double h20 = SizeConfig.blockHeight * 20;
  static double h50 = SizeConfig.blockHeight * 50;

  static double fontSmall = SizeConfig.blockWidth * 3.5;
  static double fontMedium = SizeConfig.blockWidth * 4.5;
  static double fontLarge = SizeConfig.blockWidth * 6;


  static double get paddingSmall => SizeConfig.blockWidth * 2; 
  static double get paddingMedium => SizeConfig.blockWidth * 4;
  static double get paddingLarge => SizeConfig.blockWidth * 6;


  static double get spacingSmall => SizeConfig.blockHeight * 1.5;
  static double get spacingMedium => SizeConfig.blockHeight * 3;
  static double get spacingLarge => SizeConfig.blockHeight * 5;


  static double get radiusSmall => SizeConfig.blockWidth * 2;
  static double get radiusMedium => SizeConfig.blockWidth * 4;
  static double get radiusLarge => SizeConfig.blockWidth * 6;


  static double get blurSmall => 5.0;
  static double get blurMedium => 10.0;
  static double get blurLarge => 20.0;


  static double get iconSmall => SizeConfig.blockWidth * 5;
  static double get iconMedium => SizeConfig.blockWidth * 7;
  static double get iconLarge => SizeConfig.blockWidth * 9;
  static double get iconXLarge => SizeConfig.blockWidth * 12;


  static double get cardHeight => SizeConfig.blockHeight * 20;
  static double get buttonHeight => SizeConfig.blockHeight * 7;
  static double get imageHeight => SizeConfig.blockHeight * 25;
}
