@isTest
public class DateLiteralConstant_UnitTests {
    private static integer n_number = 5;

    @isTest
    static void it_should_return_yesterday_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().YESTERDAY;
        System.assertEquals('YESTERDAY', dateLiteral.value);
    }

    @isTest
    static void it_should_return_today_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().TODAY;
        System.assertEquals('TODAY', dateLiteral.value);
    }

    @isTest
    static void it_should_return_tomorrow_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().TOMORROW;
        System.assertEquals('TOMORROW', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_week_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_WEEK;
        System.assertEquals('LAST_WEEK', dateLiteral.value);
    }

    @isTest
    static void it_should_return_this_week_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().THIS_WEEK;
        System.assertEquals('THIS_WEEK', dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_week_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_WEEK;
        System.assertEquals('NEXT_WEEK', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_month_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_MONTH;
        System.assertEquals('LAST_MONTH', dateLiteral.value);
    }

    @isTest
    static void it_should_return_this_month_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().THIS_MONTH;
        System.assertEquals('THIS_MONTH', dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_month_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_MONTH;
        System.assertEquals('NEXT_MONTH', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_ninety_days_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_90_DAYS;
        System.assertEquals('LAST_90_DAYS', dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_ninety_days_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_90_DAYS;
        System.assertEquals('NEXT_90_DAYS', dateLiteral.value);
    }

    @isTest
    static void it_should_return_this_quarter_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().THIS_QUARTER;
        System.assertEquals('THIS_QUARTER', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_quarter_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_QUARTER;
        System.assertEquals('LAST_QUARTER', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_fiscal_quarter_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_FISCAL_QUARTER;
        System.assertEquals('LAST_FISCAL_QUARTER', dateLiteral.value);
    }

    @isTest
    static void it_should_return_this_fiscal_quarter_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().THIS_FISCAL_QUARTER;
        System.assertEquals('THIS_FISCAL_QUARTER', dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_quarter_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_QUARTER;
        System.assertEquals('NEXT_QUARTER', dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_fiscal_quarter_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_FISCAL_QUARTER;
        System.assertEquals('NEXT_FISCAL_QUARTER', dateLiteral.value);
    }

    @isTest
    static void it_should_return_this_year_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().THIS_YEAR;
        System.assertEquals('THIS_YEAR', dateLiteral.value);
    }

    @isTest
    static void it_should_return_this_fiscal_year_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().THIS_FISCAL_YEAR;
        System.assertEquals('THIS_FISCAL_YEAR', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_year_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_YEAR;
        System.assertEquals('LAST_YEAR', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_fiscal_year_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_FISCAL_YEAR;
        System.assertEquals('LAST_FISCAL_YEAR', dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_year_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_YEAR;
        System.assertEquals('NEXT_YEAR', dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_fiscal_year_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_FISCAL_YEAR;
        System.assertEquals('NEXT_FISCAL_YEAR', dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_n_days_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_N_DAYS(n_number);
        System.assertEquals('LAST_N_DAYS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_n_weeks_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_N_WEEKS(n_number);
        System.assertEquals('LAST_N_WEEKS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_n_months_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_N_MONTHS(n_number);
        System.assertEquals('LAST_N_MONTHS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_n_quarters_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_N_QUARTERS(n_number);
        System.assertEquals('LAST_N_QUARTERS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_n_years_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_N_YEARS(n_number);
        System.assertEquals('LAST_N_YEARS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_last_n_fiscal_years_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().LAST_N_FISCAL_YEARS(n_number);
        System.assertEquals('LAST_N_FISCAL_YEARS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_n_days_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_N_DAYS(n_number);
        System.assertEquals('NEXT_N_DAYS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_n_weeks_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_N_WEEKS(n_number);
        System.assertEquals('NEXT_N_WEEKS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_n_months_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_N_MONTHS(n_number);
        System.assertEquals('NEXT_N_MONTHS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_n_quarters_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_N_QUARTERS(n_number);
        System.assertEquals('NEXT_N_QUARTERS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_n_fiscal_quarters_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_N_FISCAL_QUARTERS(n_number);
        System.assertEquals('NEXT_N_FISCAL_QUARTERS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_n_years_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_N_YEARS(n_number);
        System.assertEquals('NEXT_N_YEARS: ' + n_number, dateLiteral.value);
    }

    @isTest
    static void it_should_return_next_n_fiscal_years_string() {
        DateLiteralConstant dateLiteral = new DateLiteralConstant().NEXT_N_FISCAL_YEARS(n_number);
        System.assertEquals('NEXT_N_FISCAL_YEARS: ' + n_number, dateLiteral.value);
    }
}