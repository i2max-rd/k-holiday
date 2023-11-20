@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class PublicHolidayBuilder {
    global class KHolidayException extends Exception {
    }

    private List<Item> items;

    global PublicHolidayBuilder(String body) {
        //this.items = extractItems(body);
        this.items = convertItems(body);
    }

    global List<Holiday> build() {
        if (items == null || items.size() == 0) {
            return null;
        }

        List<Holiday> holidays = new List<Holiday>();

        for (Item item : items) {
            if (item.isHoliday == 'Y') {
                holidays.add(new Holiday(Name = item.dateName, ActivityDate = integerToDate(item.locdate)));
            }
        }

        return holidays;
    }

    private List<Item> convertItems(String body) {
        List<Item> result = new List<Item>();

        Map<String, Object> jsonBody = (Map<String, Object>) JSON.deserializeUntyped(body);
        Map<String, Object> response = (Map<String, Object>) jsonBody.get('response');
        Map<String, Object> responseBody = (Map<String, Object>) response.get('body');

        Integer totalCount = (Integer) responseBody.get('totalCount');

        Map<String, Object> items;

        if (totalCount >= 1) {
            items = (Map<String, Object>) responseBody.get('items');
        } else if (totalCount == 0) {
            result = null;
        } else {
            throw new KHolidayException('Unresolvable holidays');
        }

        if (totalCount == 1) {
            // 단수의 휴일
            result.add((Item) JSON.deserialize(JSON.serialize(items.get('item')), Item.class));
        } else if (totalCount > 1) {
            // 복수의 휴일
            result = (List<Item>) JSON.deserialize(JSON.serialize(items.get('item')), List<Item>.class);
        }

        return result;
    }

    /**
     * @description Convert integer to date type variable
     * @example '20230102' to Date(2023, 1, 2);
     */
    public static Date integerToDate(Integer locdate) {
        List<String> digits = String.valueOf(locdate).split('');

        String year = digits[0] + digits[1] + digits[2] + digits[3];
        String month = digits[4] + digits[5];
        String day = digits[6] + digits[7];

        return Date.valueOf(year + '-' + month + '-' + day);
    }

    public class Item {
        public String dateKind;
        public String dateName;
        public String isHoliday;
        public Integer locdate;
        public Integer seq;
    }
}