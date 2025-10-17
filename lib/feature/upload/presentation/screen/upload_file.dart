import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orbita_hackathon/core/utils/strings/app_strings.dart';
import 'package:orbita_hackathon/core/utils/widgets/background_image.dart';

import '../../../../core/utils/color/app_color.dart';

// --- Placeholder for your actual CUBIT and STATES. Remove or replace them. ---
// You should have these files in your project structure.
// This is just to make the example runnable.
abstract class ExoplanetAnalysisStates {}
class InitialAnalysisState extends ExoplanetAnalysisStates {}
class SelectingFileState extends ExoplanetAnalysisStates {}
class FileSelectedSuccessState extends ExoplanetAnalysisStates {
  final String fileName;
  final List<List<dynamic>> previewData;
  FileSelectedSuccessState({required this.fileName, required this.previewData});
}
class FileSelectionCancelledState extends ExoplanetAnalysisStates {}
class LoadingAnalysisState extends ExoplanetAnalysisStates {}
class AnalysisSuccessState extends ExoplanetAnalysisStates {}
class AnalysisFailureState extends ExoplanetAnalysisStates {
  final String message;
  AnalysisFailureState({required this.message});
}

// A mock Cubit to make the code runnable.
// Replace this with your actual Cubit import.
class ExoplanetAnalysisCubit extends Cubit<ExoplanetAnalysisStates> {
  ExoplanetAnalysisCubit() : super(InitialAnalysisState());
  File? csvFile;
  List<List<dynamic>>? csvPreviewData;
  String? selectedFileName;

  Future<void> selectCsvFile() async {
    try {
      emit(SelectingFileState());
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['csv'],
      );
      if (result != null && result.files.single.path != null) {
        csvFile = File(result.files.single.path!);
        selectedFileName = result.files.single.name;
        final fileContent = await csvFile!.readAsString();
        csvPreviewData = const CsvToListConverter().convert(fileContent);
        emit(FileSelectedSuccessState(
          fileName: selectedFileName!, previewData: csvPreviewData!,
        ));
      } else {
        emit(FileSelectionCancelledState());
      }
    } catch (e) {
      emit(FileSelectionCancelledState());
    }
  }

  Future<void> analyzeCsvFile() async {
    if (csvFile == null) return;
    emit(LoadingAnalysisState());
    // Mock analysis
    await Future.delayed(const Duration(seconds: 2));
    // emit(AnalysisSuccessState());
    emit(AnalysisFailureState(message: "This is a mock error."));
  }
}

// --- Your Actual Screen Code Starts Here ---

class ExoplanetFinderScreen extends StatelessWidget {
  const ExoplanetFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure to provide the Cubit in your widget tree above this screen
    return BlocProvider(
      create: (context) => ExoplanetAnalysisCubit(),
      child: const _ExoplanetFinderView(),
    );
  }
}

class _ExoplanetFinderView extends StatelessWidget {
  const _ExoplanetFinderView();

  @override
  Widget build(BuildContext context) {
    // Assuming you have ScreenUtilInit in your app's root
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final cubit = BlocProvider.of<ExoplanetAnalysisCubit>(context);

    return Scaffold(
      body: BlocConsumer<ExoplanetAnalysisCubit, ExoplanetAnalysisStates>(
        listener: (context, state) {
          if (state is AnalysisFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is AnalysisSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Analysis Successful!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              BackgroundImage(),

              Container(color: Colors.black.withOpacity(0.6)),

              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    const Spacer(),
                    _buildUploadArea(context, cubit, state),
                    SizedBox(height: 20),
                    _buildPreviewArea(state),
                    const Spacer(flex: 2),
                    _buildAnalyzeButton(context, cubit, state),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              // Show loading indicator over the screen
              if (state is LoadingAnalysisState)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    // Using your custom loading widget if available
                    // child: FileUploadLoading(),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 10),
          Text(
            'Exoplanet Finder',
            style: TextStyle(
                color:AppColor.textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context, ExoplanetAnalysisCubit cubit, ExoplanetAnalysisStates state) {
    return GestureDetector(
      onTap: state is LoadingAnalysisState ? null : () => cubit.selectCsvFile(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.secondColor.withOpacity(0.3),),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_outlined, color: AppColor.secondColor, size: 50),
              SizedBox(height: 15),
              Text(
                'Drag & drop or browser to upload',
                style: TextStyle(color: AppColor.secondColor, fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                'Only CSV files',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewArea(ExoplanetAnalysisStates state) {
    if (state is FileSelectedSuccessState) {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
              columns: state.previewData[0].map((header) => DataColumn(
                label: Text(header.toString(), style: const TextStyle(color: AppColor.textColor, fontWeight: FontWeight.bold)),
              )).toList(),
              rows: state.previewData.skip(1).take(5).map((row) => DataRow(
                cells: row.map((cell) => DataCell(Text(cell.toString(), style: const TextStyle(color: Colors.white70)))).toList(),
              )).toList(),
            ),
          ),
        ),
      );
    }
    return Text(
      AppStrings.uploadingFileStatement,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white54, fontSize: 16),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, ExoplanetAnalysisCubit cubit, ExoplanetAnalysisStates state) {
    final bool isEnabled = cubit.csvFile != null && state is! LoadingAnalysisState;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: isEnabled ? () => cubit.analyzeCsvFile() : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.grey.shade800.withOpacity(0.5),

        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
              colors: [AppColor.secondColor, AppColor.mainColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              'Analyze Now',
              style: TextStyle(fontSize: 18, color: isEnabled ? Colors.white : Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}

