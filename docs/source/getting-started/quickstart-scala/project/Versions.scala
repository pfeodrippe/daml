// Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

object Versions {

  val sdkVersion: String = sdkVersionFromSysProps().getOrElse("100.12.11")

  val darFileName: String = "__DAR_FILE_NAME__"

  // TODO: Leo fix it!!!
  val darFile =
    new sbt.File(
      "/home/leos/Projects/daml-experiments/java-codegen-test/dist/java-codegen-test.dar")

  println(s"DA sdkVersion: $sdkVersion")

  lazy val detectedOs: String = sys.props("os.name") match {
    case "Mac OS X" => "osx"
    case _ => "linux"
  }

  private def sdkVersionFromSysProps(): Option[String] =
    sys.props.get("DA.sdkVersion")
}
