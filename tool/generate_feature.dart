import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('❌ رجاءً اكتب اسم الـ feature: ');
    print('مثال: dart tool/generate_feature.dart login 🇪🇬');
    return;
  }

  final featureName = arguments.first.toLowerCase();
  final className = capitalize(featureName);
  final basePath = 'lib/features/$featureName';

  final folders = [
    '$basePath/domain/entities',
    '$basePath/domain/repositories',
    '$basePath/domain/usecases',
    '$basePath/data/models',
    '$basePath/data/datasources',
    '$basePath/data/repositories',
    '$basePath/presentation/cubit',
    '$basePath/presentation/pages',
  ];

  for (final folder in folders) {
    Directory(folder).createSync(recursive: true);
  }

  _createDomainFiles(basePath, featureName, className);

  _createDataFiles(basePath, featureName, className);

  _createPresentationFiles(basePath, featureName, className);

  print('✅ تم إنشاء الـ Feature "$featureName" مع الهيكل الكامل. 🇪🇬');
}

void _createDomainFiles(String basePath, String featureName, String className) {
  File(
    '$basePath/domain/entities/${featureName}_entity.dart',
  ).writeAsStringSync('''
class ${className}Entity {

}
''');

  File(
    '$basePath/domain/repositories/${featureName}_repository.dart',
  ).writeAsStringSync('''
abstract class ${className}Repository {

}
''');

  File(
    '$basePath/domain/usecases/${featureName}_usecase.dart',
  ).writeAsStringSync('''
import '../repositories/${featureName}_repository.dart';

class ${className}UseCase {
  final ${className}Repository repository;

  ${className}UseCase(this.repository);


}
''');
}

void _createDataFiles(String basePath, String featureName, String className) {
  File('$basePath/data/models/${featureName}_model.dart').writeAsStringSync('''
import '../../domain/entities/${featureName}_entity.dart';

class ${className}Model extends ${className}Entity {
  ${className}Model() : super();

  factory ${className}Model.fromJson(Map<String, dynamic> json) {
  
    return ${className}Model();
  }
}
''');

  File(
    '$basePath/data/datasources/${featureName}_remote_datasource.dart',
  ).writeAsStringSync('''
abstract class ${className}RemoteDataSource {

}
''');

  File(
    '$basePath/data/repositories/${featureName}_repository_impl.dart',
  ).writeAsStringSync('''
import '../../domain/repositories/${featureName}_repository.dart';
import '../datasources/${featureName}_remote_datasource.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  final ${className}RemoteDataSource remoteDataSource;

  ${className}RepositoryImpl(this.remoteDataSource);


}
''');
}

void _createPresentationFiles(
  String basePath,
  String featureName,
  String className,
) {
  File(
    '$basePath/presentation/cubit/${featureName}_state.dart',
  ).writeAsStringSync('''
abstract class ${className}State {}

class ${className}Initial extends ${className}State {}

class ${className}Loading extends ${className}State {}

class ${className}Success extends ${className}State {


}

class ${className}Failure extends ${className}State {
  final String error;
  ${className}Failure(this.error);
}
''');

  File(
    '$basePath/presentation/cubit/${featureName}_cubit.dart',
  ).writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';
import '${featureName}_state.dart';

class ${className}Cubit extends Cubit<${className}State> {
  ${className}Cubit() : super(${className}Initial());

  Future<void> doSomething() async {
    emit(${className}Loading());
    try {
    
    
    } catch (e) {
      emit(${className}Failure(e.toString()));
    }
  }
}
''');

  File(
    '$basePath/presentation/pages/${featureName}_page.dart',
  ).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/${featureName}_cubit.dart';
import '../cubit/${featureName}_state.dart';

class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ${className}Cubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('$className Page')),
        body: BlocBuilder<${className}Cubit, ${className}State>(
          builder: (context, state) {
            if (state is ${className}Loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ${className}Failure) {
              return Center(child: Text('Error: \${state.error}'));
            }
            return const Center(child: Text('$className Page'));
          },
        ),
      ),
    );
  }
}
''');
}

// وظيفة لكتابة أول حرف بحروف كبيرة
String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
