import 'package:flutter/material.dart';

/// Hierarchical Space Model - Supports nesting up to 10 levels
class SpaceItem {
  final String id;
  String name;
  IconData icon;
  Color color;
  final int level; // Current nesting level (0-9, max 10 levels)
  final List<SpaceItem> subSpaces;
  final List<CameraItem> cameras;
  String status;

  SpaceItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.level = 0,
    List<SpaceItem>? subSpaces,
    List<CameraItem>? cameras,
    this.status = 'active',
  })  : subSpaces = subSpaces ?? [],
        cameras = cameras ?? [];

  // Check if can add more sub-spaces (max 10 levels)
  bool canAddSubSpace() => level < 9; // 0-9 = 10 levels

  // Get total camera count (including nested spaces)
  int get totalCameraCount {
    int count = cameras.length;
    for (var subSpace in subSpaces) {
      count += subSpace.totalCameraCount;
    }
    return count;
  }

  // Get direct item count (sub-spaces + cameras)
  int get itemCount => subSpaces.length + cameras.length;
}

/// Camera Model
class CameraItem {
  final String id;
  String name;
  String location;
  String streamUrl;
  String status;

  CameraItem({
    required this.id,
    required this.name,
    required this.location,
    required this.streamUrl,
    this.status = 'online',
  });
}
