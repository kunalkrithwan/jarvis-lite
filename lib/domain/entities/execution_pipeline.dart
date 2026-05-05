/// Pipeline entity for executing sequential tasks
class ExecutionPipeline {
  final String id;
  final String name;
  final List<PipelineStage> stages;
  final PipelineStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final DateTime? startTime;
  final DateTime? endTime;

  ExecutionPipeline({
    required this.id,
    required this.name,
    required this.stages,
    this.status = PipelineStatus.pending,
    DateTime? createdAt,
    this.input = const {},
    this.output = const {},
    this.startTime,
    this.endTime,
  }) : createdAt = createdAt ?? DateTime.now();

  Duration? get executionTime {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  ExecutionPipeline copyWith({
    String? id,
    String? name,
    List<PipelineStage>? stages,
    PipelineStatus? status,
    DateTime? createdAt,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ExecutionPipeline(
      id: id ?? this.id,
      name: name ?? this.name,
      stages: stages ?? this.stages,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      input: input ?? this.input,
      output: output ?? this.output,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Represents a single stage in an execution pipeline
class PipelineStage {
  final String id;
  final String name;
  final String type; // 'command', 'validation', 'delay', 'retry'
  final Map<String, dynamic> parameters;
  final int order;
  final bool required;
  final int maxRetries;
  final Duration? timeout;
  PipelineStageStatus status;
  String? error;
  Map<String, dynamic>? result;
  int retryCount;

  PipelineStage({
    required this.id,
    required this.name,
    required this.type,
    this.parameters = const {},
    required this.order,
    this.required = true,
    this.maxRetries = 3,
    this.timeout,
    this.status = PipelineStageStatus.pending,
    this.error,
    this.result,
    this.retryCount = 0,
  });

  bool get isCompleted =>
      status == PipelineStageStatus.completed ||
      status == PipelineStageStatus.skipped;

  bool get isFailed => status == PipelineStageStatus.failed;

  bool get canRetry => retryCount < maxRetries && isFailed;
}

enum PipelineStatus { pending, running, paused, completed, failed, cancelled }

enum PipelineStageStatus {
  pending,
  running,
  completed,
  failed,
  skipped,
  retrying,
}
