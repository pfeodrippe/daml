package com.digitalasset.quickstart.iou

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import com.digitalasset.api.util.TimeProvider
import com.digitalasset.grpc.adapter.AkkaExecutionSequencerPool
import com.digitalasset.ledger.client.LedgerClient
import com.digitalasset.ledger.client.binding.{Primitive => P}
import com.digitalasset.ledger.client.configuration.{CommandClientConfiguration, LedgerClientConfiguration, LedgerIdRequirement}

import scala.concurrent.duration._
import scala.concurrent.{Await, ExecutionContext, ExecutionContextExecutor, Future}

object IouMain extends App {

  if (args.length != 3) {
    System.err.println("Usage: LEDGER_HOST LEDGER_PORT PARTY")
    System.exit(-1)
  }

  private val ledgerHost = args(0)
  private val ledgerPort = args(1).toInt
  private val party = P.Party(args(2))

  private val applicationId = this.getClass.getSimpleName
  private val timeProvider = TimeProvider.UTC

  private val asys = ActorSystem()
  private val amat = ActorMaterializer()(asys)
  private val aesf = new AkkaExecutionSequencerPool("clientPool")(asys)

  private implicit val ec: ExecutionContextExecutor = ExecutionContext.global

  private val clientConfig = LedgerClientConfiguration(
    applicationId = applicationId,
    ledgerIdRequirement = LedgerIdRequirement("", enabled = false),
    commandClient = CommandClientConfiguration.default,
    sslContext = None
  )
  private val clientF: Future[LedgerClient] =
    LedgerClient.singleHost(ledgerHost, ledgerPort, clientConfig)(ec, aesf)

  val c = Await.result(clientF, 10.seconds)

  println(s"----- $c")

}
