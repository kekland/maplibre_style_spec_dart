// TODO
import 'package:equatable/equatable.dart';

class ResolvedImage with EquatableMixin {
  const ResolvedImage();

  factory ResolvedImage.fromJson(dynamic json) {
    return const ResolvedImage();
  }

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}
