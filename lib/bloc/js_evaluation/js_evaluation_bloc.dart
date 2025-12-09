import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'js_evaluation_event.dart';
part 'js_evaluation_state.dart';

class JsEvaluationBloc extends Bloc<JsEvaluationEvent, JsEvaluationState> {
  JsEvaluationBloc() : super(JsEvaluationInitial()) {
    on<JsEvaluationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
