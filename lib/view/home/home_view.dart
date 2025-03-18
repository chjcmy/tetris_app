// lib/view/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris_app/models/score.dart';
import 'package:tetris_app/service/score/score_service.dart';
import 'package:tetris_app/view/base_view.dart';
import 'package:tetris_app/view/home/home_view_model.dart';
import 'package:tetris_app/view/home/widget/home_app_bar.dart';
import 'package:tetris_app/view/home/widget/home_bottom_bar.dart';
import 'package:tetris_app/view/home/widget/home_content.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final scoreService = context.read<ScoreService>();

    // 홈 화면이 처음 로드될 때 점수 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scoreService.add(LoadScores());
    });

    late final HomeViewModel homeViewModel = HomeViewModel();

    return BaseView(
      viewModel: homeViewModel,
      builder: (context, viewModel) {
        return Scaffold(
          appBar: const HomeAppBar(),
          bottomNavigationBar: const HomeBottomBar(),
          body: BlocBuilder<ScoreService, ScoreState>(
            builder: (context, scoreState) {
              // 로딩 상태 처리
              if (scoreState is ScoreLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // 에러 상태 처리
              if (scoreState is ScoreError) {
                return Center(child: Text('오류: ${scoreState.message}'));
              }

              final List<Score> scores =
                  scoreState is ScoreLoaded ? scoreState.scores : [];

              return HomeContent(
                scoreList: scores,
                error: viewModel.state.error,
                sortType: viewModel.state.sortType,
                onSortChanged: (sortType) {
                  // 정렬 버튼들의 선택을 알리기 위해 전달
                  viewModel.add(SortScoreList(sortType));
                  // 스코어의 정렬을 변경하기 위해 ScoreService에 이벤트 전달
                  scoreService.add(SortScores(sortType));
                },
              );
            },
          ),
        );
      },
    );
  }
}
