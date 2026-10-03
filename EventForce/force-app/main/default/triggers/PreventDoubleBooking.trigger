trigger PreventDoubleBooking on Event__c (before insert, before update) {

    Set<Id> venueIds = new Set<Id>();
    Set<Date> eventDates = new Set<Date>();

    // Collect Venue and Date from new/updated events
    for (Event__c ev : Trigger.new) {
        if (ev.Venue__c != null && ev.Event_Date__c != null) {
            venueIds.add(ev.Venue__c);
            eventDates.add(ev.Event_Date__c);
        }
    }

    if (venueIds.isEmpty() || eventDates.isEmpty()) {
        return;
    }

    // Get existing events for the same venues and dates
    List<Event__c> existingEvents = [
        SELECT Id, Venue__c, Event_Date__c
        FROM Event__c
        WHERE Venue__c IN :venueIds
        AND Event_Date__c IN :eventDates
    ];

    // Compare new/updated events with existing events
    for (Event__c ev : Trigger.new) {

        if (ev.Venue__c == null || ev.Event_Date__c == null) {
            continue;
        }

        for (Event__c existing : existingEvents) {

            // Don't compare the record with itself during update
            if (existing.Id == ev.Id) {
                continue;
            }

            // Same venue + same date = duplicate booking
            if (existing.Venue__c == ev.Venue__c &&
                existing.Event_Date__c == ev.Event_Date__c) {

                ev.addError(
                    'This Venue is already booked on this date.'
                );
            }
        }
    }
}