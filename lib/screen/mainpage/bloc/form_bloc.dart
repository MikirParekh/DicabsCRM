import 'package:bloc/bloc.dart';
import 'package:dicabs/screen/mainpage/model/form_data_model.dart';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  final MainPageRepository dataRepository;
    FormBloc(this.dataRepository) : super(FormInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(FormLoading());
      try {
        final categories = await dataRepository.fetchCategories();
        emit(CategoriesLoaded(categories));
      } catch (e) {
        emit(FormSubmissionFailure(e.toString()));
      }
    });

    on<SubmitForm>((event, emit) async {
      emit(FormLoading());
      try {
        await dataRepository.submitForm(event.formData,event.userCode,event.salesCode);
        emit(FormSubmissionSuccess());
      } catch (e) {
        emit(FormSubmissionFailure(e.toString()));
      }
    });
  }
}
