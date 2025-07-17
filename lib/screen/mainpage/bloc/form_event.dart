part of 'form_bloc.dart';

@immutable
sealed class FormEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class LoadCategories extends FormEvent {}

class SubmitForm extends FormEvent {
  final AddActivityList formData;
  final String userCode;
  final String salesCode;
  SubmitForm(this.userCode, this.salesCode, {required this.formData});

  @override
  List<Object> get props => [formData,userCode,salesCode];
}
