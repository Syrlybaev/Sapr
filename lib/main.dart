import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saprbar_desktop/features/home/bloc/file_bloc.dart';
import 'package:saprbar_desktop/features/home/cubit/home_cubit.dart';
import 'package:saprbar_desktop/features/post/presentation/cubit/post_cubit.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';
import 'package:saprbar_desktop/core/repository/project_repository.dart';
import 'package:saprbar_desktop/features/pro/data/repositories/processor_repository.dart';
import 'package:saprbar_desktop/features/pro/presentation/cubit/processor_cubit.dart';
import 'package:saprbar_desktop/sapr_bar_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Directory projectsDir = Directory('${dir.path}/saprbar_projects');
  if (!await projectsDir.exists()) {
    await projectsDir.create(recursive: true);
  }
  final projectRepository = ProjectRepository(projectsDir: projectsDir);

  final proRepository = ProcessorRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeCubit(projectRepository: projectRepository),
        ),
        BlocProvider(create: (_) => PreBloc(projectRepository)),
        BlocProvider(create: (_) => FileBloc(projectRepository)),
        BlocProvider(
          create: (_) => ProcessorCubit(proRepository: proRepository),
        ),
        BlocProvider(create: (_) => PostCubit()),
      ],
      child: SaprBarApp(),
    ),
  );
}
