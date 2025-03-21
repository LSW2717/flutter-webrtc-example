// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$viewModelHash() => r'6ac921b8040598442a97013016927f6af2ef86a7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ViewModel extends BuildlessAutoDisposeNotifier<State> {
  late final String channelId;

  State build(
    String channelId,
  );
}

/// See also [ViewModel].
@ProviderFor(ViewModel)
const viewModelProvider = ViewModelFamily();

/// See also [ViewModel].
class ViewModelFamily extends Family<State> {
  /// See also [ViewModel].
  const ViewModelFamily();

  /// See also [ViewModel].
  ViewModelProvider call(
    String channelId,
  ) {
    return ViewModelProvider(
      channelId,
    );
  }

  @override
  ViewModelProvider getProviderOverride(
    covariant ViewModelProvider provider,
  ) {
    return call(
      provider.channelId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'viewModelProvider';
}

/// See also [ViewModel].
class ViewModelProvider
    extends AutoDisposeNotifierProviderImpl<ViewModel, State> {
  /// See also [ViewModel].
  ViewModelProvider(
    String channelId,
  ) : this._internal(
          () => ViewModel()..channelId = channelId,
          from: viewModelProvider,
          name: r'viewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$viewModelHash,
          dependencies: ViewModelFamily._dependencies,
          allTransitiveDependencies: ViewModelFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelId,
  }) : super.internal();

  final String channelId;

  @override
  State runNotifierBuild(
    covariant ViewModel notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(ViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ViewModelProvider._internal(
        () => create()..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelId: channelId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ViewModel, State> createElement() {
    return _ViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ViewModelProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ViewModelRef on AutoDisposeNotifierProviderRef<State> {
  /// The parameter `channelId` of this provider.
  String get channelId;
}

class _ViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ViewModel, State>
    with ViewModelRef {
  _ViewModelProviderElement(super.provider);

  @override
  String get channelId => (origin as ViewModelProvider).channelId;
}

String _$micStateHash() => r'4c4ca104d32fa64135a79afd742c17570f325c9c';

/// See also [MicState].
@ProviderFor(MicState)
final micStateProvider = NotifierProvider<MicState, bool>.internal(
  MicState.new,
  name: r'micStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$micStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MicState = Notifier<bool>;
String _$camStateHash() => r'2657f0270259a4ce1d1b208bbc98593a8529a94a';

/// See also [CamState].
@ProviderFor(CamState)
final camStateProvider = NotifierProvider<CamState, bool>.internal(
  CamState.new,
  name: r'camStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$camStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CamState = Notifier<bool>;
String _$faceStateHash() => r'2846f2c4a9b090d621dae11a6e33aa94b3bd109a';

/// See also [FaceState].
@ProviderFor(FaceState)
final faceStateProvider = NotifierProvider<FaceState, bool>.internal(
  FaceState.new,
  name: r'faceStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$faceStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FaceState = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
