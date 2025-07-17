part of 'form_bloc.dart';


@immutable
sealed class FormState extends Equatable {
  @override
  List<Object> get props => [];
}

class FormInitial extends FormState {}

class FormLoading extends FormState {}

class CategoriesLoaded extends FormState {
  final List<String> categories;

  CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class FormSubmissionSuccess extends FormState {}

class FormSubmissionFailure extends FormState {
  final String error;

  FormSubmissionFailure(this.error);

  @override
  List<Object> get props => [error];
}
