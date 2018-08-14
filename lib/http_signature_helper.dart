library http_signature_helper;

import 'package:auth_params/auth_params.dart';
import 'package:collection/collection.dart';

class SignatureTarget {
  final String method;
  final String path;

  SignatureTarget(this.method, this.path);
}

class SignatureNonce {
  final String clientId;
  final String nonce;

  SignatureNonce(this.clientId, this.nonce);

  @override
  bool operator ==(other) {
    return clientId == other.clientId && nonce == other.nonce;
  }
}

class SignatureString {
  final String body;
  final Map<String, String> headers;
  final List<String> signatureHeaders;
  final SignatureTarget target;
  final SignatureNonce nonce;

  SignatureString(
      {this.body,
      Map<String, String> headers = const <String, String>{},
      List<String> signatureHeaders = const <String>[],
      this.target,
      this.nonce})
      : this.headers =
            headers?.map((key, value) => MapEntry(key.toLowerCase(), value)),
        this.signatureHeaders = signatureHeaders
            ?.map((signatureHeader) => signatureHeader.toLowerCase())
            ?.toList();

  @override
  String toString() {
    final lines = List<String>();

    if (nonce != null) {
      lines.add("${nonce.clientId} ${nonce.nonce}");
    }

    if (signatureHeaders.contains("(request-target)") && target != null) {
      lines.add(
          "(request-target): ${target.method.toLowerCase()} ${target.path}");
    }

    signatureHeaders.forEach((signatureHeader) {
      if (!headers.containsKey(signatureHeader)) {
        // Header is in [signatureHeaders], but not in [headers], skip
        return;
      }
      final header = headers[signatureHeader]
          .split("\n")
          .map((header) => header.trim())
          .join(" ");
      lines.add("$signatureHeader: $header");
    });

    if (body != null) {
      lines.add(body);
    }

    return lines.join("\n");
  }
}

class SignatureHeader {
  final String keyId;
  final String algorithm;
  final String signature;
  final List<String> signatureHeaders;
  final SignatureNonce nonce;
  final bool prefixed;

  SignatureHeader(
      {this.keyId,
      this.algorithm,
      this.signature,
      List<String> signatureHeaders = const <String>[],
      this.nonce,
      this.prefixed = true})
      : this.signatureHeaders = signatureHeaders
            ?.map((signatureHeader) => signatureHeader.toLowerCase())
            ?.toList();

  @override
  String toString() {
    final output = Map<String, String>();

    if (keyId != null) {
      output["keyId"] = keyId;
    }
    if (algorithm != null) {
      output["algorithm"] = algorithm;
    }
    if (signatureHeaders != null) {
      output["headers"] = signatureHeaders.join(" ");
    }
    if (signature != null) {
      output["signature"] = signature;
    }
    if (nonce != null) {
      output["clientId"] = nonce.clientId;
      output["nonce"] = nonce.nonce;
    }

    return (prefixed ? "Signature " : "") + authParams.encode(output);
  }

  factory SignatureHeader.parse(String input, [bool prefixed = true]) {
    if (prefixed && input.startsWith("Signature ")) {
      input = input.replaceFirst("Signature ", "");
    }
    final decoded = authParams.decode(input);

    return SignatureHeader(
      keyId: decoded["keyId"],
      algorithm: decoded["algorithm"],
      signatureHeaders: decoded["headers"]?.split(" "),
      signature: decoded["signature"],
      nonce: decoded["nonce"] != null
          ? SignatureNonce(
              decoded["clientId"],
              decoded["nonce"],
            )
          : null,
    );
  }

  @override
  bool operator ==(other) {
    if (keyId != other.keyId) {
      return false;
    }
    if (algorithm != other.algorithm) {
      return false;
    }
    if (keyId != other.keyId) {
      return false;
    }
    if (signature != other.signature) {
      return false;
    }
    if (!ListEquality().equals(signatureHeaders, other.signatureHeaders)) {
      return false;
    }
    if (nonce != other.nonce) {
      return false;
    }
    if (prefixed != other.prefixed) {
      return false;
    }

    return true;
  }
}
