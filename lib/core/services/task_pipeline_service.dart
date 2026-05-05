import 'package:jarvis_lite/domain/entities/execution_pipeline.dart';

/// Task Pipeline Execution Engine
/// Executes commands sequentially with:
/// - Task queuing
/// - Async execution
/// - Retry mechanism
/// - Error handling
/// - Voice feedback at each stage
abstract class TaskPipelineService {
  /// Create and return a new execution pipeline
  ExecutionPipeline createPipeline({
    required String name,
    required List<PipelineStage> stages,
    required Map<String, dynamic> input,
  });

  /// Execute a pipeline
  /// Returns stream of pipeline status updates
  Stream<ExecutionPipeline> executePipeline(ExecutionPipeline pipeline);

  /// Get pipeline by ID
  Future<ExecutionPipeline?> getPipeline(String id);

  /// Cancel running pipeline
  Future<void> cancelPipeline(String id);

  /// Pause pipeline execution
  Future<void> pausePipeline(String id);

  /// Resume paused pipeline
  Future<void> resumePipeline(String id);

  /// Get execution history
  Future<List<ExecutionPipeline>> getExecutionHistory({int limit = 50});

  /// Clear history
  Future<void> clearHistory();
}

/// Default implementation of Task Pipeline Service
class DefaultTaskPipelineService implements TaskPipelineService {
  final Map<String, ExecutionPipeline> _activePipelines = {};
  final List<ExecutionPipeline> _history = [];
  static const int _maxHistorySize = 100;

  @override
  ExecutionPipeline createPipeline({
    required String name,
    required List<PipelineStage> stages,
    required Map<String, dynamic> input,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return ExecutionPipeline(id: id, name: name, stages: stages, input: input);m
  }

  @override
  Stream<ExecutionPipeline> executePipeline(ExecutionPipeline pipeline) async* {
    final pipelineId = pipeline.id;
    _activePipelines[pipelineId] = pipeline;

    try {
      var currentPipeline = pipeline.copyWith(
        status: PipelineStatus.running,
        startTime: DateTime.now(),
      );

      yield currentPipeline;

      // Execute stages sequentially
      for (final stage in currentPipeline.stages) {
        if (_activePipelines[pipelineId]?.status == PipelineStatus.cancelled) {
          currentPipeline = currentPipeline.copyWith(
            status: PipelineStatus.cancelled,
          );
          yield currentPipeline;
          return;
        }

        if (_activePipelines[pipelineId]?.status == PipelineStatus.paused) {
          // Wait for resume
          while (_activePipelines[pipelineId]?.status ==
              PipelineStatus.paused) {
            await Future.delayed(Duration(milliseconds: 100));
          }
        }

        // Execute stage with retry logic
        final stageResult = await _executeStageWithRetry(stage, currentPipeline);
        stage.status = stageResult.status;
        stage.result = stageResult.result;
        stage.error = stageResult.error;

        yield currentPipeline;

        if (stageResult.status == PipelineStageStatus.failed &&
            stage.required) {
          currentPipeline = currentPipeline.copyWith(
            status: PipelineStatus.failed,
            endTime: DateTime.now(),
          );
          yield currentPipeline;
          return;
        }
      }

      currentPipeline = currentPipeline.copyWith(
        status: PipelineStatus.completed,
        endTime: DateTime.now(),
      );
      yield currentPipeline;

      // Add to history
      _addToHistory(currentPipeline);
    } catch (e) {
      var failedPipeline = pipeline.copyWith(
        status: PipelineStatus.failed,
        endTime: DateTime.now(),
      );
      yield failedPipeline;
      _addToHistory(failedPipeline);
    } finally {
      _activePipelines.remove(pipelineId);
    }
  }

  Future<PipelineStage> _executeStageWithRetry(
    PipelineStage stage,
    ExecutionPipeline pipeline,
  ) async {
    while (true) {
      try {
        stage.status = PipelineStageStatus.running;

        // Simulate stage execution with timeout
        final timeout = stage.timeout ?? Duration(seconds: 30);
        await Future.delayed(Duration(milliseconds: 500)).timeout(timeout);

        stage.status = PipelineStageStatus.completed;
        stage.result = {'message': 'Stage ${stage.name} completed'};
        return stage;
      } catch (e) {
        stage.retryCount++;
        if (stage.canRetry) {
          stage.status = PipelineStageStatus.retrying;
          await Future.delayed(Duration(seconds: 1));
        } else {
          stage.status = PipelineStageStatus.failed;
          stage.error = e.toString();
          return stage;
        }
      }
    }
  }

  @override
  Future<ExecutionPipeline?> getPipeline(String id) async {
    return _activePipelines[id];
  }

  @override
  Future<void> cancelPipeline(String id) async {
    if (_activePipelines.containsKey(id)) {
      final pipeline = _activePipelines[id]!;
      _activePipelines[id] = pipeline.copyWith(status: PipelineStatus.cancelled);
    }
  }

  @override
  Future<void> pausePipeline(String id) async {
    if (_activePipelines.containsKey(id)) {
      final pipeline = _activePipelines[id]!;
      _activePipelines[id] = pipeline.copyWith(status: PipelineStatus.paused);
    }
  }

  @override
  Future<void> resumePipeline(String id) async {
    if (_activePipelines.containsKey(id)) {
      final pipeline = _activePipelines[id]!;
      _activePipelines[id] = pipeline.copyWith(status: PipelineStatus.running);
    }
  }

  @override
  Future<List<ExecutionPipeline>> getExecutionHistory({int limit = 50}) async {
    return _history.take(limit).toList();
  }

  @override
  Future<void> clearHistory() async {
    _history.clear();
  }

  void _addToHistory(ExecutionPipeline pipeline) {
    _history.insert(0, pipeline);
    if (_history.length > _maxHistorySize) {
      _history.removeRange(_maxHistorySize, _history.length);
    }
  }
}
