import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:math';

import 'constants.dart';
import 'package:clipboard/clipboard.dart';
import 'package:duration/duration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class Labelled extends StatelessWidget {
  const Labelled(
      {Key? key,
      required this.label,
      required this.value,
      this.unit = '',
      this.fontSize = 20})
      : super(key: key);

  final String label;
  final String value;
  final String unit;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$label: ",
            style:
                GoogleFonts.capriola(textStyle: TextStyle(fontSize: fontSize))),
        Text("$value $unit",
            style: GoogleFonts.capriola(
                textStyle: TextStyle(
                    fontSize: fontSize,
                    color: colorOrange,
                    fontWeight: FontWeight.bold))),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "ZaMatic by Pizzatarians",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: materialColorOrange,
        ),
        initialRoute: "/",
        routes: {
          "/": (context) => const PizzaBot(title: "ZaMatic by Pizzatarians"),
        },
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
              builder: (context) {
                return PizzaBot(
                    title: "ZaMatic by Pizzatarians", bookmark: settings.name);
              },
              maintainState: false,
              settings: settings);
        });
  }
}

class Recipe {}

class PizzaBot extends StatefulWidget {
  const PizzaBot({Key? key, required this.title, this.bookmark})
      : super(key: key);

  final String title;
  final String? bookmark;

  @override
  State<PizzaBot> createState() => _PizzaBotState();
}

class _PizzaBotState extends State<PizzaBot>
    with SingleTickerProviderStateMixin {
  static double referenceSize = 12;
  static double referenceCount = 8;
  static double referenceBallMass = 275;
  static double referenceRoomTemp = 72;
  static double referenceControlledTemp = 40;
  static const double tTime = 96;
  final style = GoogleFonts.capriola(textStyle: const TextStyle(fontSize: 25));

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideAnimation2;
  late Animation<Offset> _slideAnimation3;
  late Animation<Offset> _slideAnimation4;
  late Animation<Offset> _slideAnimation5;

  bool displayHelp = false;
  bool printLayout = false;
  double size = referenceSize;
  double minSize = 6;
  double maxSize = 16;
  int divSize = 20;

  double count = referenceCount;
  double minCount = 1;
  double maxCount = 100;

  double roomTemp = referenceRoomTemp;
  double controlledTemp = referenceControlledTemp;
  double thickness = 100;
  double hydration = 62.0;
  double salinity = 3.5;
  double rtTime = 24;
  double ctTime = 0;

  bool isShort = true;
  String _version = 'x.x.x';

  String permalink() =>
      "/${count.toStringAsFixed(0)}/${size.toStringAsFixed(1)}/${thickness.toStringAsFixed(1)}/${hydration.toStringAsFixed(0)}/${salinity.toStringAsFixed(0)}/${roomTemp.toStringAsFixed(2)}/${rtTime.toStringAsFixed(0)}/${ctTime.toStringAsFixed(0)}";

  double _area(double diameter) => pow((diameter / 2), 2) * pi;
  double _centimeters(double size) => size * 2.54;
  double _celsius(double temp) => (temp - 32) * 5 / 9;
  double _ratio(double area) => area / _referenceArea();
  double _referenceArea() => _area(referenceSize);
  double ballMass() =>
      _ratio(_area(size)) * referenceBallMass * (thickness / 100);

  double doughMass() => ballMass() * count;
  double salineHydration() => hydration + (salinity * hydration / 100);

  double flourMass() => doughMass() / (1 + (salineHydration() * 0.01));
  double saltWaterMass() => doughMass() - flourMass();

  double waterMass() => saltWaterMass() / (1 + (salinity * 0.01));
  double saltMass() => saltWaterMass() - waterMass();

  double adjustedTime() => rtTime + ctTime - (9 * ctTime) / 10;
  double W() => 81.4206918743428 + 78.3939060802556 * log(rtTime + ctTime);
  double yeastFactor() =>
      (2250 * (1 + salinity / 200)) /
      ((4.2 * hydration - 80 - 0.0305 * hydration * hydration) *
          pow(_celsius(roomTemp), 2.5) *
          pow(adjustedTime(), 1.2));

  double forza() => 10.0 * (W() * 0.1).round();
  double yeastMass() => (flourMass() * yeastFactor());

  final Map<double, String> thicknesss = {
    75: 'Tortilla Style (ultrathin)',
    87.5: 'Milan Style (thin)',
    100: 'Napoli Style (regular)',
    112.5: 'Rome Style (thick)',
    125: 'UFO Style (ultrathick)',
  };
  String thicknessWords() => thicknesss[thickness] ?? 'Unknown';

  final Map<double, String> salinities = {
    1: 'Very Light',
    1.5: 'Light',
    2: 'Very Light',
    2.5: 'Very Light',
    3: 'Light',
    3.5: 'Light',
    4: 'Pizzatarians',
    4.5: 'Pizzatarians',
    5: 'Recommended',
    5.5: 'Recommended',
    6: 'Standard',
    6.5: 'Standard',
    7: 'High',
    7.5: 'High',
    8: 'Very High',
  };
  String salinityWords() => salinities[salinity] ?? 'Unknown';

  String permalinkUri() =>
      Uri.encodeFull("https://matic.pizzatarians.com/#${permalink()}");

  QrImageView qrImage() {
    return QrImageView(
      data: permalinkUri(),
      version: QrVersions.auto,
      size: 320,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: colorOrange,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: colorOrange,
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget txtRecipe() {
    return SelectableText(
      isShort ? bakersPercentRecipeStringShort() : bakersPercentRecipeString(),
      style: courierPrime.copyWith(color: Colors.blue[900], fontSize: 16),
      showCursor: true,
      cursorWidth: 2,
      cursorColor: Colors.blue,
      cursorRadius: const Radius.circular(2),
    );
  }

  String bakersPercentRecipeString() {
    return """
YIELD
$count x ${size.toStringAsFixed(1)}" (${_centimeters(size).toStringAsFixed(0)} cm) Pizza${count > 1 ? 's' : ''}
${ballMass().toStringAsFixed(0)} g dough ball
${doughMass().toStringAsFixed(0)} g total mass

INFO
Salinity ${((10 * salinity)).toStringAsFixed(0)} g/L
Hydration ${hydration.toStringAsFixed(0)}%
Suggested W${forza().toStringAsFixed(0)}

Room Temperature: $roomTemp F (${_celsius(roomTemp).toStringAsFixed(1)} C)
Room Fermentation: $rtTime hours
Refrigerated Fermentation: $ctTime hours
Total Fermentation ${prettyDuration(Duration(hours: (ctTime + rtTime).toInt()))} ${ctTime + rtTime >= 24 ? '(${ctTime + rtTime} h)' : ''}

FULL RECIPE
${formatRecipe("""FLOUR\t${flourMass().toStringAsFixed(0)} g\t100 %
WATER\t${waterMass().toStringAsFixed(0)} g\t${(waterMass() / flourMass() * 100).toStringAsFixed(0)} %
SALT\t${saltMass().toStringAsFixed(1)} g\t${(saltMass() / flourMass() * 100).toStringAsFixed(1)} %
YEAST\t${yeastMass().toStringAsFixed(3)} g\t${(yeastMass() / flourMass() * 100).toStringAsFixed(2)} %""", 40)}

1/2 RECIPE
${formatRecipe("""FLOUR\t${(0.5 * flourMass()).toStringAsFixed(0)} g
WATER\t${(0.5 * waterMass()).toStringAsFixed(0)} g
SALT\t${(0.5 * saltMass()).toStringAsFixed(1)} g
YEAST\t${(0.5 * yeastMass()).toStringAsFixed(3)} g""", 40)}

1/3 RECIPE
${formatRecipe("""FLOUR\t${(0.333 * flourMass()).toStringAsFixed(0)} g
WATER\t${(0.333 * waterMass()).toStringAsFixed(0)} g
SALT\t${(0.333 * saltMass()).toStringAsFixed(1)} g
YEAST\t${(0.333 * yeastMass()).toStringAsFixed(3)} g""", 40)}

1/4 RECIPE
${formatRecipe("""FLOUR\t${(0.25 * flourMass()).toStringAsFixed(0)} g
WATER\t${(0.25 * waterMass()).toStringAsFixed(0)} g
SALT\t${(0.25 * saltMass()).toStringAsFixed(1)} g
YEAST\t${(0.25 * yeastMass()).toStringAsFixed(3)} g""", 40)}

PERMALINK
${permalinkUri()}
""";
  }

  String bakersPercentRecipeStringShort() {
    return """
INFO
$count x ${size.toStringAsFixed(1)}" (${_centimeters(size).toStringAsFixed(0)} cm) Pizza${count > 1 ? 's' : ''}
${ballMass().toStringAsFixed(0)} g dough ball
${doughMass().toStringAsFixed(0)} g total mass
Total Fermentation ${prettyDuration(Duration(hours: (ctTime + rtTime).toInt()))} ${ctTime + rtTime >= 24 ? '(${ctTime + rtTime} h)' : ''}

FULL RECIPE
${formatRecipe("""FLOUR\t${flourMass().toStringAsFixed(0)} g\t100 %\nWATER\t${waterMass().toStringAsFixed(0)} g\t${(waterMass() / flourMass() * 100).toStringAsFixed(0)} %\nSALT\t${saltMass().toStringAsFixed(1)} g\t${(saltMass() / flourMass() * 100).toStringAsFixed(1)} %\nYEAST\t${yeastMass().toStringAsFixed(3)} g\t${(yeastMass() / flourMass() * 100).toStringAsFixed(2)} %""", 40)}
1/2 RECIPE
${formatRecipe("""FLOUR\t${(0.5 * flourMass()).toStringAsFixed(0)} g
WATER\t${(0.5 * waterMass()).toStringAsFixed(0)} g
SALT\t${(0.5 * saltMass()).toStringAsFixed(1)} g
YEAST\t${(0.5 * yeastMass()).toStringAsFixed(3)} g""", 40)}
1/4 RECIPE
${formatRecipe("""FLOUR\t${(0.25 * flourMass()).toStringAsFixed(0)} g
WATER\t${(0.25 * waterMass()).toStringAsFixed(0)} g
SALT\t${(0.25 * saltMass()).toStringAsFixed(1)} g
YEAST\t${(0.25 * yeastMass()).toStringAsFixed(3)} g""", 40)}""";
  }

  Map<String, String> bakersPercentRecipeData() {
    return {
      'fullRecipeC1': """
FLOUR
WATER
SALT
YEAST
""",
      'fullRecipeC2': """
${flourMass().toStringAsFixed(0)}g
${waterMass().toStringAsFixed(0)}g
${saltMass().toStringAsFixed(1)}g
${yeastMass().toStringAsFixed(3)}g
""",
      'fullRecipeC3': """
100%
${(waterMass() / flourMass() * 100).toStringAsFixed(0)}%
${(saltMass() / flourMass() * 100).toStringAsFixed(1)}%
${(yeastMass() / flourMass() * 100).toStringAsFixed(2)}%
""",
      'halfRecipe': """
1/2 RECIPE

  FLOUR ${(0.5 * flourMass()).toStringAsFixed(0)}g
  WATER ${(0.5 * waterMass()).toStringAsFixed(0)}g
  SALT ${(0.5 * saltMass()).toStringAsFixed(1)}g
  YEAST ${(0.5 * yeastMass()).toStringAsFixed(3)}g
""",
      'thirdRecipe': """
1/3 RECIPE

  FLOUR ${(0.33 * flourMass()).toStringAsFixed(0)}g
  WATER ${(0.33 * waterMass()).toStringAsFixed(0)}g
  SALT ${(0.33 * saltMass()).toStringAsFixed(1)}g
  YEAST ${(0.33 * yeastMass()).toStringAsFixed(3)}g
""",
      'fourthRecipe': """
1/4 RECIPE

  FLOUR ${(0.25 * flourMass()).toStringAsFixed(0)}g
  WATER ${(0.25 * waterMass()).toStringAsFixed(0)}g
  SALT ${(0.25 * saltMass()).toStringAsFixed(1)}g
  YEAST ${(0.25 * yeastMass()).toStringAsFixed(3)}g
""",
      'yield': """
$count x ${size.toStringAsFixed(1)}" (${_centimeters(size).toStringAsFixed(0)} cm) Pizza${count > 1 ? 's' : ''}

${ballMass().toStringAsFixed(0)} g dough ball
${doughMass().toStringAsFixed(0)} g total mass
""",
      'info': """
Salinity ${((10 * salinity)).toStringAsFixed(0)} g/L
Hydration ${hydration.toStringAsFixed(0)}%
Suggested W${forza().toStringAsFixed(0)}
""",
      'fermentation': """
Room Temperature: $roomTemp F (${_celsius(roomTemp).toStringAsFixed(1)} C)
Room Fermentation: $rtTime hours
Refrigerated Fermentation: $ctTime hours
Total Fermentation ${prettyDuration(Duration(hours: (ctTime + rtTime).toInt()))} ${ctTime + rtTime >= 24 ? '(${ctTime + rtTime} h)' : ''}
""",
      'permalinkUri': permalinkUri()
    };
  }

  void copyRecipeToClipboard({bool short = false}) async {
    await FlutterClipboard.copy(
        short ? bakersPercentRecipeStringShort() : bakersPercentRecipeString());
  }

  String formatRecipe(String recipeText, int totalWidth) {
    List<String> lines = recipeText.split('\n');
    List<int> maxColumnLengths = List.filled(3, 0); // Assuming 3 columns

    // Calculate max length of each column
    for (String line in lines) {
      List<String> columns = line.split('\t');
      for (int i = 0; i < columns.length; i++) {
        maxColumnLengths[i] = max(maxColumnLengths[i], columns[i].length);
      }
    }

    // Calculate column widths based on rule of thirds
    int column1Width = maxColumnLengths[0];
    int column2Width =
        column1Width + ((totalWidth - column1Width) * 2 / 3).round();
    int column3Width = totalWidth;

    // Format each line
    String formattedText = '';
    for (String line in lines) {
      List<String> columns = line.split('\t');
      String formattedLine = columns[0].padRight(column1Width);
      formattedLine += columns[1].padLeft(column2Width - column1Width);
      if (columns.length > 2) {
        formattedLine += columns[2].padLeft(column3Width - column2Width);
      }
      formattedText += '$formattedLine\n';
    }

    return formattedText;
  }

  Widget appVersion() {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text("VERSION $_version",
            style: courierPrime.copyWith(fontSize: 12, color: colorGray)));
  }

  // INPUT
  // pizza diameter, pizza thickness => ball weight
  // number of balls => dough weight
  // hydration level => flour / water ratio => flour weight, water weight

  void evaluateBookmark() {
    if (widget.bookmark == null) return;

    final tokens = widget.bookmark?.split('/');
    if (tokens!.isNotEmpty && tokens.length == 9) {
      final _count = double.parse(tokens[1]);
      final _size = double.parse(tokens[2]);
      final _thickness = double.parse(tokens[3]);
      final _hydration = double.parse(tokens[4]);
      final _salinity = double.parse(tokens[5]);
      final _roomTemp = double.parse(tokens[6]);
      final _rtTime = double.parse(tokens[7]);
      final _ctTime = double.parse(tokens[8]);

      if ((_size % ((maxSize - minSize) / divSize) != 0) ||
          (_count < minCount || _count > maxCount) ||
          (false)) {
        return;
      }

      setState(() {
        count = _count;
        size = _size;
        thickness = _thickness;
        hydration = _hydration;
        salinity = _salinity;
        roomTemp = _roomTemp;
        rtTime = _rtTime;
        ctTime = _ctTime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1550),
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut, // Apply desired curve here
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.95), end: Offset.zero)
            .animate(curvedAnimation);
    _slideAnimation2 =
        Tween<Offset>(begin: const Offset(0, -4.5), end: Offset.zero)
            .animate(curvedAnimation);
    _slideAnimation3 =
        Tween<Offset>(begin: const Offset(0, -6.5), end: Offset.zero)
            .animate(curvedAnimation);
    _slideAnimation4 =
        Tween<Offset>(begin: const Offset(0, -8.5), end: Offset.zero)
            .animate(curvedAnimation);
    _slideAnimation5 =
        Tween<Offset>(begin: const Offset(0, -19.5), end: Offset.zero)
            .animate(curvedAnimation);

    evaluateBookmark();
    getVersion().then((version) {
      setState(() {
        _version = version;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, Map recipe) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final monoFont = await PdfGoogleFonts.shareTechMonoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('YOUR RECIPE',
                      style: pw.TextStyle(
                          fontSize: 24,
                          font: monoFont,
                          color: PdfColors.black)),
                  pw.Text(DateFormat.yMMMMd().add_jm().format(DateTime.now()),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          font: monoFont,
                          fontSize: 14,
                          color: PdfColor.fromHex('#095da0'))),
                ],
              ),
              pw.Container(height: 20),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(recipe['yield'],
                        style: pw.TextStyle(font: monoFont, fontSize: 18)),
                    pw.Text(recipe['info'],
                        style: pw.TextStyle(font: monoFont, fontSize: 16),
                        textAlign: pw.TextAlign.justify)
                  ]),
              pw.Container(height: 20),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text(recipe['fullRecipeC1'],
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            font: monoFont,
                            fontSize: 24,
                            color: PdfColor.fromHex('#333333'))),
                    pw.Text(('.' * 3 + '\n') * 4,
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                            font: monoFont,
                            fontSize: 24,
                            color: PdfColor.fromHex('#cccccc'))),
                    pw.Text(recipe['fullRecipeC2'],
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            font: monoFont,
                            fontSize: 24,
                            color: PdfColor.fromHex('#333333'))),
                    pw.Text(('.' * 12 + '\n') * 4,
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                            font: monoFont,
                            fontSize: 24,
                            color: PdfColor.fromHex('#cccccc'))),
                    pw.Text(recipe['fullRecipeC3'],
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            font: monoFont,
                            fontSize: 24,
                            color: PdfColor.fromHex('#333333')))
                  ]),
              pw.Container(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(recipe['halfRecipe'],
                      style: pw.TextStyle(font: monoFont, fontSize: 14)),
                  pw.Text(recipe['thirdRecipe'],
                      style: pw.TextStyle(font: monoFont, fontSize: 14)),
                  pw.Text(recipe['fourthRecipe'],
                      style: pw.TextStyle(font: monoFont, fontSize: 14)),
                ],
              ),
              pw.Container(height: 20),
              pw.Text(recipe['fermentation'],
                  style: pw.TextStyle(font: monoFont, fontSize: 15)),
              pw.Container(height: 20),
              pw.Expanded(
                  child: pw.Text("NOTES",
                      style: pw.TextStyle(
                          font: monoFont,
                          fontSize: 15,
                          color: PdfColor.fromHex('#cccccc')))),
              pw.FittedBox(
                  child: pw.UrlLink(
                      destination: recipe['permalinkUri'],
                      child: pw.Text(recipe['permalinkUri'],
                          style: pw.TextStyle(
                              font: monoFont,
                              fontSize: 14,
                              color: PdfColor.fromHex('#095da0'))))),
              pw.Container(height: 20),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      height: 60,
                      width: 60,
                      child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: recipe['permalinkUri'],
                          drawText: false,
                          color: PdfColor.fromHex('#095da0')),
                    ),
                    pw.Text('ZaMATIC',
                        style: pw.TextStyle(
                            fontSize: 24,
                            font: monoFont,
                            color: PdfColor.fromHex('#095da0'))),
                  ]),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Widget printPageContent() {
    return PdfPreview(
      build: (format) => _generatePdf(format, bakersPercentRecipeData()),
    );
  }

  Widget botPageContent(double width) {
    final bool resized = width < 777;
    final double labelSize = resized ? 15 : 25;
    final style =
        GoogleFonts.capriola(textStyle: TextStyle(fontSize: resized ? 20 : 30));
    return Center(
      child: Container(
        decoration:
            const BoxDecoration(color: Color.fromRGBO(255, 234, 179, 0.5)),
        constraints: const BoxConstraints.expand(width: 888),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22.0),
                    child: Column(
                      children: [
                        Ink(
                          decoration: ShapeDecoration(
                            color: displayHelp ? colorOrange : colorHelp,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.help),
                            tooltip: 'HELP',
                            onPressed: () {
                              setState(() {
                                displayHelp = !displayHelp;
                                if (displayHelp) {
                                  _controller.forward();
                                  // Fades in the widgets
                                } else {
                                  _controller.reverse();
                                  // Fades out the widgets
                                }
                              });
                              final snackBar = SnackBar(
                                duration: const Duration(milliseconds: 750),
                                content: Text(
                                    "ZaMatic help system is ${displayHelp ? 'ON' : 'OFF'}",
                                    style: style.copyWith(color: colorOrange)),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text("HELP ME",
                              style: style.copyWith(
                                  fontSize: 18,
                                  color:
                                      displayHelp ? colorOrange : colorHelp)),
                        )
                      ],
                    ),
                  ),
                  SlideTransition(
                      position: _slideAnimation,
                      child: Visibility(
                          visible: displayHelp,
                          child: HelpText("Measurements of your pizza",
                              body: measurementTextHelp, style: style))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                            'Diameter (Pizza Size):  ${size.toStringAsFixed(1)}" (${_centimeters(size).toStringAsFixed(0)} cm)',
                            style: style)
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor: Colors.grey,
                            valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            activeTrackColor: colorOrange,
                            activeTickMarkColor: colorOrange,
                            inactiveTrackColor: Colors.grey[400],
                            inactiveTickMarkColor: Colors.grey[400],
                            thumbColor: Colors.white,
                            overlayColor: colorOrange.withAlpha(75),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25),
                          ),
                          child: Slider(
                            min: minSize,
                            max: maxSize,
                            value: size,
                            divisions: divSize,
                            // label:
                            //     "${size.toStringAsFixed(1)}\" (${_centimeters(size).toStringAsFixed(0)} cm)",
                            onChanged: (value) {
                              setState(() {
                                size = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Thickness: ${thicknessWords()}', style: style)
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor: Colors.grey,
                            valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            activeTrackColor: colorOrange,
                            activeTickMarkColor: colorOrange,
                            inactiveTrackColor: Colors.grey[400],
                            inactiveTickMarkColor: Colors.grey[400],
                            thumbColor: Colors.white,
                            overlayColor: colorOrange.withAlpha(75),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25),
                          ),
                          child: Slider(
                            min: 75,
                            max: 125,
                            value: thickness,
                            divisions: 4,
                            // label: "${thickness.toStringAsFixed(2)}%",
                            onChanged: (value) {
                              setState(() {
                                thickness = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text('How many pizzas? $count', style: style),
                          Ink(
                            decoration: const ShapeDecoration(
                              color: Colors.red,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              iconSize: 42.0,
                              icon: const Icon(Icons.remove),
                              tooltip: 'Less',
                              onPressed: () {
                                setState(() {
                                  if (count > 1) count--;
                                });
                              },
                            ),
                          ),
                          Ink(
                            decoration: const ShapeDecoration(
                              color: Colors.green,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              iconSize: 42.0,
                              icon: const Icon(Icons.add),
                              tooltip: 'More',
                              onPressed: () {
                                setState(() {
                                  count++;
                                });
                              },
                            ),
                          )
                        ]),
                  ),
                  SlideTransition(
                      position: _slideAnimation2,
                      child: Visibility(
                          visible: displayHelp,
                          child: HelpText(
                              'Water and Salt concentrations in the dough',
                              body: hydrationTextHelp,
                              style: style))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Hydration: ${hydration.toStringAsFixed(0)}%',
                            style: style)
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor: Colors.grey,
                            valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            activeTrackColor: colorOrange,
                            activeTickMarkColor: colorOrange,
                            inactiveTrackColor: Colors.grey[400],
                            inactiveTickMarkColor: Colors.grey[400],
                            thumbColor: Colors.white,
                            overlayColor: colorOrange.withAlpha(75),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25),
                          ),
                          child: Slider(
                            min: 50,
                            max: 100,
                            divisions: 50,
                            value: hydration,
                            // label: "${hydration.toStringAsFixed(1)}%",
                            onChanged: (value) {
                              setState(() {
                                hydration = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                            'Salinity: ${((10 * salinity)).toStringAsFixed(0)} g/L (${salinityWords()})',
                            style: style)
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor: Colors.grey,
                            valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            activeTrackColor: colorOrange,
                            activeTickMarkColor: colorOrange,
                            inactiveTrackColor: Colors.grey[400],
                            inactiveTickMarkColor: Colors.grey[400],
                            thumbColor: Colors.white,
                            overlayColor: colorOrange.withAlpha(75),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25),
                          ),
                          child: Slider(
                            min: 2,
                            max: 8,
                            divisions: 12,
                            value: salinity,
                            // label: "${((10 * salinity)).toStringAsFixed(0)} g/L",
                            onChanged: (value) {
                              setState(() {
                                salinity = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SlideTransition(
                      position: _slideAnimation3,
                      child: Visibility(
                          visible: displayHelp,
                          child: HelpText(
                              'Fermentation type, duration and temperature',
                              body: fermentationTextHelp,
                              style: style))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                            'Room Temperature: $roomTemp F (${_celsius(roomTemp).toStringAsFixed(1)} C)',
                            style: style)
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor:
                                Color.fromARGB(255, 34, 31, 31),
                            valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            activeTrackColor: colorOrange,
                            activeTickMarkColor: colorOrange,
                            inactiveTrackColor: Colors.grey[400],
                            inactiveTickMarkColor: Colors.grey[400],
                            thumbColor: Colors.white,
                            overlayColor: colorOrange.withAlpha(75),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25),
                          ),
                          child: Slider(
                            min: 62,
                            max: 77,
                            divisions: 15,
                            value: roomTemp,
                            // label:
                            //     " $roomTemp F (${_celsius(roomTemp).toStringAsFixed(1)} C)",
                            onChanged: (value) {
                              setState(() {
                                roomTemp = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Room Fermentation: $rtTime hours', style: style)
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor:
                                Color.fromARGB(255, 34, 31, 31),
                            valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            activeTrackColor: Colors.red[300],
                            activeTickMarkColor: Colors.red[300],
                            inactiveTrackColor: Colors.grey[400],
                            inactiveTickMarkColor: Colors.grey[400],
                            thumbColor: Colors.white,
                            overlayColor: colorOrange.withAlpha(75),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25),
                          ),
                          child: Slider(
                            min: 1,
                            max: tTime,
                            value: rtTime,
                            // label: " $rtTime",
                            onChanged: (value) {
                              setState(() {
                                rtTime = value.floorToDouble();
                                ctTime = [tTime - rtTime, ctTime].reduce(min);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Refrigerated Fermentation: $ctTime hours',
                            style: style)
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorColor:
                                Color.fromARGB(255, 34, 31, 31),
                            valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            activeTrackColor:
                                Color.fromARGB(255, 100, 181, 246),
                            activeTickMarkColor: Colors.blue[300],
                            inactiveTrackColor: Colors.grey[400],
                            inactiveTickMarkColor: Colors.grey[400],
                            thumbColor: Colors.white,
                            overlayColor: Colors.blue.withAlpha(75),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 15),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25),
                          ),
                          child: Slider(
                            min: 0,
                            max: tTime - 1,
                            value: ctTime,
                            label: " $ctTime",
                            onChanged: (value) {
                              setState(() {
                                ctTime = value.floorToDouble();
                                rtTime = [tTime - ctTime, rtTime].reduce(min);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SlideTransition(
                      position: _slideAnimation4,
                      child: Visibility(
                          visible: displayHelp,
                          child: HelpText('Timeline of the process',
                              body: timelineTextHelp, style: style))),
                  Container(height: 10),
                  Text('Timeline', style: style),
                  Container(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Labelled(
                            label: 'IMPASTO (Ingredients Mixing)',
                            value: '5-30 min',
                            fontSize: labelSize),
                      ]),
                  Container(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Labelled(
                            label: 'PUNTATA (Bulk Fermentation)',
                            value: (ctTime + rtTime >= 3)
                                ? "${prettyDuration(Duration(hours: (ctTime + rtTime).toInt()))} ${ctTime + rtTime >= 24 ? '(${ctTime + rtTime} hrs)' : ''}"
                                : 'not long enough',
                            fontSize: labelSize),
                      ]),
                  Container(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Labelled(
                            label: 'STAGLIO (Cutting and Balling)',
                            value: '${(count * 2).toStringAsFixed(0)} min',
                            fontSize: labelSize),
                      ]),
                  Container(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Labelled(
                            label: 'APPRETTO (Balled Fermentation)',
                            value: '2-6 hrs',
                            fontSize: labelSize),
                      ]),
                  Container(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Labelled(
                            label: 'STESURA & COTTURA(Shaping and Baking)',
                            value: 'up to you!',
                            fontSize: labelSize),
                      ]),
                  Container(height: 30),
                  SlideTransition(
                      position: _slideAnimation5,
                      child: Visibility(
                          visible: displayHelp,
                          child: HelpText('What to pick up at the store',
                              body: ingredientsTextHelp, style: style))),
                  Text('Ingredients', style: style),
                  Container(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: [
                          Labelled(
                              label: 'Flour',
                              value: flourMass().toStringAsFixed(0),
                              unit: 'g',
                              fontSize: labelSize + 7),
                          Labelled(
                              label: 'Table Salt',
                              value: saltMass().toStringAsFixed(1),
                              unit: 'g',
                              fontSize: labelSize + 7)
                        ],
                      ),
                      Column(
                        children: [
                          Labelled(
                              label: 'Water',
                              value: waterMass().toStringAsFixed(0),
                              unit: 'g',
                              fontSize: labelSize + 7),
                          Labelled(
                              label: 'Dry Yeast',
                              value: yeastMass().toStringAsFixed(3),
                              unit: 'g',
                              fontSize: labelSize + 7),
                        ],
                      ),
                    ],
                  ),
                  Container(height: 30),
                  Text('Stats', style: style),
                  Container(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          children: [
                            Labelled(
                              fontSize: labelSize + 7,
                              label: 'Pizza Count',
                              value: count.toStringAsFixed(0),
                            ),
                            Labelled(
                                fontSize: labelSize + 7,
                                label: 'Ball Mass',
                                value: ballMass().toStringAsFixed(0),
                                unit: 'g'),
                          ],
                        ),
                        Column(
                          children: [
                            Labelled(
                                fontSize: labelSize + 7,
                                label: 'Dough Mass',
                                value: (doughMass()).toStringAsFixed(0),
                                unit: 'g'),
                            Labelled(
                                fontSize: labelSize + 7,
                                label: 'Strength',
                                value: forza().toStringAsFixed(0),
                                unit: 'W'),
                          ],
                        ),
                      ]),
                  Container(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: [
                          Ink(
                            decoration: const ShapeDecoration(
                              color: Colors.blue,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              iconSize: 42.0,
                              icon: const Icon(Icons.save),
                              tooltip: 'SAVE URL',
                              onPressed: () {
                                FlutterClipboard.copy(permalinkUri());
                                final snackBar = SnackBar(
                                  content: Text(
                                      "The unique URL of this recipe was copied to your clipboard (and will be saved in your browser's history)",
                                      style:
                                          style.copyWith(color: Colors.white)),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);

                                Navigator.pushNamedAndRemoveUntil(
                                    context, permalink(), (route) => false);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text("SAVE URL",
                                style: style.copyWith(
                                    fontSize: 18,
                                    color: materialColorOrange[800])),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Ink(
                            decoration: const ShapeDecoration(
                              color: Colors.green,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              iconSize: 42.0,
                              icon: const Icon(Icons.picture_as_pdf),
                              tooltip: 'OPEN PDF',
                              onPressed: () {
                                setState(() {
                                  printLayout = true;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text("OPEN PDF",
                                style: style.copyWith(
                                    fontSize: 18,
                                    color: materialColorOrange[800])),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Ink(
                            decoration: const ShapeDecoration(
                              color: Color.fromARGB(255, 165, 166, 246),
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              iconSize: 42.0,
                              icon: const Icon(Icons.text_snippet_rounded),
                              tooltip: 'COPY RECIPE TEXT TO CLIPBOARD',
                              onPressed: () {
                                copyRecipeToClipboard();
                                final snackBar = SnackBar(
                                  content: Text(
                                      "The complete recipe was copied to your clipboard!",
                                      style:
                                          style.copyWith(color: Colors.white)),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text("COPY TEXT",
                                style: style.copyWith(
                                    fontSize: 18,
                                    color: materialColorOrange[800])),
                          )
                        ],
                      ),
                    ],
                  ),
                  Container(height: 50),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                  child: Text(
                                    'FULL',
                                    style: style.copyWith(
                                        color: isShort
                                            ? colorGray.withOpacity(0.3)
                                            : colorGray,
                                        fontSize: 14),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isShort = false;
                                    });
                                  }),
                              TextButton(
                                  child: Text(
                                    'SHORT',
                                    style: style.copyWith(
                                        color: isShort
                                            ? colorGray
                                            : colorGray.withOpacity(0.3),
                                        fontSize: 14),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isShort = true;
                                    });
                                  }),
                            ]),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text("TXT RECIPE",
                              style: style.copyWith(
                                  color: materialColorOrange[800])),
                        ),
                      ),
                      Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                  child: Text(
                                    'COPY',
                                    style: style.copyWith(
                                        color: colorGray, fontSize: 14),
                                  ),
                                  onPressed: () {
                                    copyRecipeToClipboard(short: isShort);
                                    final snackBar = SnackBar(
                                      content: Text(
                                          "The ${isShort ? 'short' : 'complete'} recipe was copied to your clipboard!",
                                          style: style.copyWith(
                                              color: Colors.white)),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }),
                            ]),
                      )
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12.0)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 50, horizontal: 40),
                          child: txtRecipe())),
                  Column(
                    children: [
                      Text("QRC RECIPE",
                          style:
                              style.copyWith(color: materialColorOrange[800])),
                      qrImage(),
                      Container(height: 50),
                      Text("YOUR PERMALINK",
                          style:
                              style.copyWith(color: materialColorOrange[800])),
                      TextButton(
                        child: Text(
                          permalinkUri(),
                          style: style.copyWith(color: colorGray, fontSize: 22),
                        ),
                        onPressed: () {
                          FlutterClipboard.copy(permalinkUri());
                          final snackBar = SnackBar(
                            content: Text(
                                "The unique URL of this recipe was copied to your clipboard (and will be saved in your browser's history)",
                                style: style.copyWith(color: Colors.white)),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          Navigator.pushNamedAndRemoveUntil(
                              context, permalink(), (route) => false);
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 222.0),
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: () {
                              final url =
                                  Uri.parse('https://www.pizzatarians.com');
                              launchUrl(url);
                            },
                            child: Text('PIZZATARIANS.COM',
                                style: GoogleFonts.bebasNeue().copyWith(
                                    fontSize: 66,
                                    color: Colors.blueGrey[600]))),
                        Text('THE JOY, SCIENCE AND CRAFT OF #PIZZA',
                            style: GoogleFonts.bebasNeue().copyWith(
                                fontSize: 44, color: materialColorOrange[800])),
                        appVersion()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(widget.title,
                style: style.copyWith(color: Colors.blueGrey[600])),
            leading: printLayout
                ? GestureDetector(
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                    onTap: () {
                      setState(() {
                        printLayout = false;
                      });
                    },
                  )
                : null,
          ),
          body: printLayout
              ? printPageContent()
              : botPageContent(constraints.maxWidth));
    });
  }
}

class HelpText extends StatelessWidget {
  final String text;
  final String body;
  final TextStyle style;

  const HelpText(this.text, {this.body = '', super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorHelp.withOpacity(0.5),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              text,
              style: style,
            ),
            Text(
              body,
              style: style.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
