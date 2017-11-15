package notebok.front.widgets.magic

import java.text.SimpleDateFormat
import java.util.GregorianCalendar

import notebook.front.widgets.magic.AnyPoint
import org.scalatest.FunSuite
import org.scalatest.prop.TableDrivenPropertyChecks

class AnyPointTest extends FunSuite with TableDrivenPropertyChecks {

  private val javaUtilDate = new GregorianCalendar(2017, 9, 19, 12, 30, 33).getTime
  private val javaSqlTimestamp = new java.sql.Timestamp(javaUtilDate.getTime)
  private val javaSqlDate = new java.sql.Date(javaUtilDate.getTime)

  private val localTimeZone = new SimpleDateFormat("Z").format(javaUtilDate)

  private val expected = s"2017-10-19 12:30:33 Thu $localTimeZone"

  test("Date like value is converted to format expected by java script") {
    val testData = Table[Any, Seq[String]](
      ("in", "out")
      ,(javaUtilDate, Seq(expected))
      ,(javaSqlTimestamp, Seq(expected))
      ,(javaSqlDate, Seq(expected))
      ,(ClassWithDates(javaUtilDate, javaSqlTimestamp, javaSqlDate), Seq.fill(3)(expected))
    )

    forAll(testData) {
      (in, out) => assert (
        AnyPoint(in).values === out
      )
    }
  }

  case class ClassWithDates(javaDate: java.util.Date, sqlTs: java.sql.Timestamp, sqlDate: java.sql.Date)
}