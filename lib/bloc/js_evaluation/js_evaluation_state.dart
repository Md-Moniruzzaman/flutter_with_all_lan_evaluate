part of 'js_evaluation_bloc.dart';

sealed class JsEvaluationState extends Equatable {
  const JsEvaluationState();
  
  @override
  List<Object> get props => [];
}

final class JsEvaluationInitial extends JsEvaluationState {}
