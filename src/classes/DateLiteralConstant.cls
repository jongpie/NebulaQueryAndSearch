public class DateLiteralConstant {
    private String LAST_N = 'LAST_N_{0}: {1}';
    private String NEXT_N = 'NEXT_N_{0}: {1}';

    private final String DAYS            = 'DAYS';
    private final String WEEKS           = 'WEEKS';
    private final String MONTHS          = 'MONTHS';
    private final String QUARTERS        = 'QUARTERS';
    private final String FISCAL_QUARTERS = 'FISCAL_QUARTERS';
    private final String YEARS           = 'YEARS';
    private final String FISCAL_YEARS    = 'FISCAL_YEARS';

    public String value {get;set;}

    public DateLiteralConstant(){}

    private DateLiteralConstant(String value) {
        this.value = value;
    }

    //Actual constant literals
    public DateLiteralConstant YESTERDAY {
        get {
            return new DateLiteralConstant('YESTERDAY');
        }
    }

    public DateLiteralConstant TODAY {
        get {
            return new DateLiteralConstant('TODAY');
        }
    }

    public DateLiteralConstant TOMORROW {
        get {
            return new DateLiteralConstant('TOMORROW');
        }
    }

    public DateLiteralConstant LAST_WEEK {
        get {
            return new DateLiteralConstant('LAST_WEEK');
        }
    }

    public DateLiteralConstant THIS_WEEK {
        get {
            return new DateLiteralConstant('THIS_WEEK');
        }
    }

    public DateLiteralConstant NEXT_WEEK {
        get {
            return new DateLiteralConstant('NEXT_WEEK');
        }
    }

    public DateLiteralConstant LAST_MONTH {
        get {
            return new DateLiteralConstant('LAST_MONTH');
        }
    }

    public DateLiteralConstant THIS_MONTH {
        get {
            return new DateLiteralConstant('THIS_MONTH');
        }
    }

    public DateLiteralConstant NEXT_MONTH {
        get {
            return new DateLiteralConstant('NEXT_MONTH');
        }
    }

    public DateLiteralConstant LAST_90_DAYS {
        get {
            return new DateLiteralConstant('LAST_90_DAYS');
        }
    }

    public DateLiteralConstant NEXT_90_DAYS {
        get {
            return new DateLiteralConstant('NEXT_90_DAYS');
        }
    }

    public DateLiteralConstant THIS_QUARTER {
        get {
            return new DateLiteralConstant('THIS_QUARTER');
        }
    }

    public DateLiteralConstant THIS_FISCAL_QUARTER {
        get {
            return new DateLiteralConstant('THIS_FISCAL_QUARTER');
        }
    }

    public DateLiteralConstant LAST_QUARTER {
        get {
            return new DateLiteralConstant('LAST_QUARTER');
        }
    }

    public DateLiteralConstant LAST_FISCAL_QUARTER {
        get {
            return new DateLiteralConstant('LAST_FISCAL_QUARTER');
        }
    }

    public DateLiteralConstant NEXT_QUARTER {
        get {
            return new DateLiteralConstant('NEXT_QUARTER');
        }
    }

    public DateLiteralConstant NEXT_FISCAL_QUARTER {
        get {
            return new DateLiteralConstant('NEXT_FISCAL_QUARTER');
        }
    }

    public DateLiteralConstant THIS_YEAR {
        get {
            return new DateLiteralConstant('THIS_YEAR');
        }
    }

    public DateLiteralConstant THIS_FISCAL_YEAR {
        get {
            return new DateLiteralConstant('THIS_FISCAL_YEAR');
        }
    }

    public DateLiteralConstant LAST_YEAR {
        get {
            return new DateLiteralConstant('LAST_YEAR');
        }
    }

    public DateLiteralConstant LAST_FISCAL_YEAR {
        get {
            return new DateLiteralConstant('LAST_FISCAL_YEAR');
        }
    }

    public DateLiteralConstant NEXT_YEAR {
        get {
            return new DateLiteralConstant('NEXT_YEAR');
        }
    }

    public DateLiteralConstant NEXT_FISCAL_YEAR {
        get {
            return new DateLiteralConstant('NEXT_FISCAL_YEAR');
        }
    }

    ////Buildable literals
    public DateLiteralConstant LAST_N_DAYS(Integer num) {
        String constant = String.format(LAST_N, new List<String>{DAYS,String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant LAST_N_WEEKS(Integer num) {
        String constant = String.format(LAST_N, new List<String>{WEEKS, String.valueof(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant LAST_N_MONTHS(Integer num) {
        String constant = String.format(LAST_N, new List<String>{MONTHS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant LAST_N_QUARTERS(Integer num) {
        String constant = String.format(LAST_N, new List<String>{QUARTERS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant LAST_N_YEARS(Integer num) {
        String constant = String.format(LAST_N, new List<String>{YEARS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant LAST_N_FISCAL_YEARS(Integer num) {
        String constant = String.format(LAST_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant NEXT_N_DAYS(Integer num) {
        String constant = String.format(NEXT_N, new List<String>{DAYS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant NEXT_N_WEEKS(Integer num) {
        String constant = String.format(NEXT_N, new List<String>{WEEKS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant NEXT_N_MONTHS(Integer num) {
        String constant = String.format(NEXT_N, new List<String>{MONTHS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant NEXT_N_QUARTERS(Integer num) {
        String constant = String.format(NEXT_N, new List<String>{QUARTERS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant NEXT_N_YEARS(Integer num) {
        String constant = String.format(NEXT_N, new List<String>{YEARS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant NEXT_N_FISCAL_QUARTERS(Integer num) {
        String constant = String.format(NEXT_N, new List<String>{FISCAL_QUARTERS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }

    public DateLiteralConstant NEXT_N_FISCAL_YEARS(Integer num) {
        String constant = String.format(NEXT_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return new DateLiteralConstant(constant);
    }
}