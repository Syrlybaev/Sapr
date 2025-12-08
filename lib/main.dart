import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saprbar_desktop/features/home/bloc/file_bloc.dart';
import 'package:saprbar_desktop/features/home/cubit/home_cubit.dart';
import 'package:saprbar_desktop/features/pre/bloc/pre_bloc.dart';
import 'package:saprbar_desktop/core/repository/project_repository.dart';
import 'package:saprbar_desktop/sapr_bar_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Directory projectsDir = Directory('${dir.path}/saprbar_projects');
  if (!await projectsDir.exists()) {
    await projectsDir.create(recursive: true);
  }
  final nodeRepository = ProjectRepository(projectsDir: projectsDir);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => PreBloc(nodeRepository)),
        BlocProvider(create: (_) => FileBloc(nodeRepository)),
      ],
      child: SaprBarApp(),
    ),
  );
}
