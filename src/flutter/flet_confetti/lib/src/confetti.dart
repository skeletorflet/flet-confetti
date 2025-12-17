import 'dart:convert';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flet/flet.dart';
import 'package:flutter/material.dart';

class ConfettiControl extends StatefulWidget {
  final Control control;

  const ConfettiControl({Key? key, required this.control}) : super(key: key);

  @override
  State<ConfettiControl> createState() => _ConfettiControlState();
}

class _ConfettiControlState extends State<ConfettiControl> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
        duration: const Duration(seconds: 10)); // Default duration
    widget.control.addListener(_update);
    widget.control.addInvokeMethodListener(_handleMethod);
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.control.removeListener(_update);
    widget.control.removeInvokeMethodListener(_handleMethod);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  Future<dynamic> _handleMethod(String methodName, dynamic args) async {
    switch (methodName) {
      case "play":
        _controller.play();
        return null;
      case "stop":
        _controller.stop();
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Confetti build: ${widget.control.id}");

    var blastDirectionality =
        widget.control.getString("blast_directionality") == "explosive"
            ? BlastDirectionality.explosive
            : BlastDirectionality.directional;
    var blastDirection = widget.control.getDouble("blast_direction", pi)!;
    var emissionFrequency =
        widget.control.getDouble("emission_frequency", 0.02)!;
    var numberOfParticles = widget.control.getInt("number_of_particles", 10)!;
    var shouldLoop = widget.control.getBool("should_loop", false)!;
    var maxBlastForce = widget.control.getDouble("max_blast_force", 20)!;
    var minBlastForce = widget.control.getDouble("min_blast_force", 5)!;
    var displayTarget = widget.control.getBool("display_target", false)!;
    var strokeWidth = widget.control.getDouble("stroke_width", 0)!;
    var gravity = widget.control.getDouble("gravity", 0.1)!;
    var particleDrag = widget.control.getDouble("particle_drag", 0.05)!;

    var minParticleWidth = widget.control.getDouble("min_particle_width", 20)!;
    var minParticleHeight =
        widget.control.getDouble("min_particle_height", 10)!;
    var maxParticleWidth = widget.control.getDouble("max_particle_width", 20)!;
    var maxParticleHeight =
        widget.control.getDouble("max_particle_height", 10)!;

    List<Color>? colors;
    var colorsJson = widget.control.getString("colors_json");
    if (colorsJson != null) {
      try {
        var parsedColors = jsonDecode(colorsJson);
        if (parsedColors is List) {
          colors = parseColors(parsedColors, Theme.of(context));
          debugPrint("Confetti Dart: Parsed colors: $colors");
        }
      } catch (e) {
        debugPrint("Error parsing colors JSON: $e");
      }
    }
    Color? strokeColor = widget.control.getColor("stroke_color", context, null);
    var shape = widget.control.getString("shape", "circle");

    var customShapeJson = widget.control.getString("custom_shape_json");
    debugPrint("Confetti Dart: Received custom_shape_json: $customShapeJson");

    if (customShapeJson != null) {
      shape = "custom";
      debugPrint("Confetti Dart: Shape set to custom");
    } else {
      debugPrint("Confetti Dart: Shape defaults to $shape");
    }

    return ConstrainedControl(
      control: widget.control,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirectionality: blastDirectionality,
        blastDirection: blastDirection,
        emissionFrequency: emissionFrequency,
        numberOfParticles: numberOfParticles,
        shouldLoop: shouldLoop,
        maxBlastForce: maxBlastForce,
        minBlastForce: minBlastForce,
        displayTarget: displayTarget,
        colors: colors,
        strokeWidth: strokeWidth,
        strokeColor: strokeColor ?? Colors.black,
        gravity: gravity,
        particleDrag: particleDrag,
        minimumSize: Size(minParticleWidth, minParticleHeight),
        maximumSize: Size(maxParticleWidth, maxParticleHeight),
        createParticlePath: (size) => _getShapePath(shape, size),
      ),
    );
  }

  Path _getShapePath(String? shape, Size size) {
    if (shape == "custom") {
      var customShapeJson = widget.control.getString("custom_shape_json");
      if (customShapeJson != null) {
        try {
          var j = jsonDecode(customShapeJson);
          return buildPath(j);
        } catch (e) {
          debugPrint("Error parsing custom shape: $e");
        }
      }
    }

    switch (shape) {
      case "square":
        return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      case "circle":
        return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
      case "star":
        return _drawStar(size);
      case "heart":
        return _drawHeart(size);
      case "triangle":
        return _drawTriangle(size);
      case "diamond":
        return _drawDiamond(size);
      default:
        return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    }
  }

  Path _drawStar(Size size) {
    // simple 5 point star
    double cx = size.width / 2;
    double cy = size.height / 2;
    double outerRadius = size.width / 2;
    double innerRadius = size.width / 5;
    Path path = Path();
    double angle = -pi / 2;
    double step = pi / 5;

    path.moveTo(cx + outerRadius * cos(angle), cy + outerRadius * sin(angle));
    for (int i = 1; i < 5; i++) {
      angle += step;
      path.lineTo(cx + innerRadius * cos(angle), cy + innerRadius * sin(angle));
      angle += step;
      path.lineTo(cx + outerRadius * cos(angle), cy + outerRadius * sin(angle));
    }
    path.close();
    return path;
  }

  Path _drawHeart(Size size) {
    Path path = Path();
    path.moveTo(0.5 * size.width, 0.35 * size.height);
    path.cubicTo(0.2 * size.width, 0.1 * size.height, -0.25 * size.width,
        0.6 * size.height, 0.5 * size.width, size.height);
    path.moveTo(0.5 * size.width, 0.35 * size.height);
    path.cubicTo(0.8 * size.width, 0.1 * size.height, 1.25 * size.width,
        0.6 * size.height, 0.5 * size.width, size.height);
    path.close();
    return path;
  }

  Path _drawTriangle(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  Path _drawDiamond(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  Path buildPath(dynamic j) {
    var path = Path();
    if (j == null) {
      return path;
    }
    for (var elem in (j as List)) {
      var type = elem["_type"];
      if (type == "MoveTo") {
        path.moveTo(parseDouble(elem["x"], 0)!, parseDouble(elem["y"], 0)!);
      } else if (type == "LineTo") {
        path.lineTo(parseDouble(elem["x"], 0)!, parseDouble(elem["y"], 0)!);
      } else if (type == "Arc") {
        path.addArc(
            Rect.fromLTWH(
                parseDouble(elem["x"], 0)!,
                parseDouble(elem["y"], 0)!,
                parseDouble(elem["width"], 0)!,
                parseDouble(elem["height"], 0)!),
            parseDouble(elem["start_angle"], 0)!,
            parseDouble(elem["sweep_angle"], 0)!);
      } else if (type == "ArcTo") {
        path.arcToPoint(
            Offset(parseDouble(elem["x"], 0)!, parseDouble(elem["y"], 0)!),
            radius: Radius.circular(parseDouble(elem["radius"], 0)!),
            rotation: parseDouble(elem["rotation"], 0)!,
            largeArc: parseBool(elem["large_arc"], false)!,
            clockwise: parseBool(elem["clockwise"], true)!);
      } else if (type == "Oval") {
        path.addOval(Rect.fromLTWH(
            parseDouble(elem["x"], 0)!,
            parseDouble(elem["y"], 0)!,
            parseDouble(elem["width"], 0)!,
            parseDouble(elem["height"], 0)!));
      } else if (type == "Rect") {
        var borderRadius = parseBorderRadius(elem["border_radius"]);
        path.addRRect(RRect.fromRectAndCorners(
            Rect.fromLTWH(
                parseDouble(elem["x"], 0)!,
                parseDouble(elem["y"], 0)!,
                parseDouble(elem["width"], 0)!,
                parseDouble(elem["height"], 0)!),
            topLeft: borderRadius?.topLeft ?? Radius.zero,
            topRight: borderRadius?.topRight ?? Radius.zero,
            bottomLeft: borderRadius?.bottomLeft ?? Radius.zero,
            bottomRight: borderRadius?.bottomRight ?? Radius.zero));
      } else if (type == "QuadraticTo") {
        path.conicTo(
            parseDouble(elem["cp1x"], 0)!,
            parseDouble(elem["cp1y"], 0)!,
            parseDouble(elem["x"], 0)!,
            parseDouble(elem["y"], 0)!,
            parseDouble(elem["w"], 0)!);
      } else if (type == "CubicTo") {
        path.cubicTo(
            parseDouble(elem["cp1x"], 0)!,
            parseDouble(elem["cp1y"], 0)!,
            parseDouble(elem["cp2x"], 0)!,
            parseDouble(elem["cp2y"], 0)!,
            parseDouble(elem["x"], 0)!,
            parseDouble(elem["y"], 0)!);
      } else if (type == "SubPath") {
        path.addPath(buildPath(elem["elements"]),
            Offset(parseDouble(elem["x"], 0)!, parseDouble(elem["y"], 0)!));
      } else if (type == "Close") {
        path.close();
      }
    }
    return path;
  }
}
