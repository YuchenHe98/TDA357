/**** Errors *****/
/* Test: registered student registering again */
INSERT INTO registrations (student, course) VALUES (2222222222, 'CCC222');
/* ERROR:  The student is either registered or on the waiting list. It is not possible to try to register twice! */

/* Test: waitlisted student registering again */
INSERT INTO registrations (student, course) VALUES (3333333333, 'CCC222');
/* ERROR:  The student is either registered or on the waiting list. It is not possible to try to register twice! */

/* Test: Unregister a student that is on the waiting list */
"DELETE FROM registrations WHERE student = 2222222222 AND course = 'CCC333';"
/* ERROR:  The student is never registered. Cannot remove. */

/**** Normal (Please do those tests in sequential order) *****/
/* Test: register to an unlimited course */
INSERT INTO registrations (student, course) VALUES (2222222222, 'CCC111');
/* Registered successfully and can be seen in the view registrations. Now 8 rows. */

/* Test: register to a limited course */
INSERT INTO registrations (student, course) VALUES (4444444444, 'CCC333');
/* Registered successfully and can be seen in the view registrations. Now 9 rows. */

/* Test: waiting for a limited course */
INSERT INTO registrations (student, course) VALUES (4444444444, 'CCC222');
/* 4444444444 is put on the WaitingList with position 2 of CCC222. Now 10 rows. */

/* Test: Unregistered from an unlimited course */
DELETE FROM registrations WHERE student = 2222222222 AND course = 'CCC111';
/* The registration is removed. Now 9 rows. */

/* Test: Unregistered from an limited course with waiting list*/
"DELETE FROM registrations WHERE student = 4444444444 AND course = 'CCC333'
/* The registration is removed. 3333333333 on the waiting list of CCC333, position 1, is now registered. 1111111111's position becomes 1. Now 8 rows. */

/* Test: Unregistered from an overfull course */
DELETE FROM registrations WHERE student = 2222222222 AND course = 'CCC222';
/* The registration is removed. Now 7 rows. The waiting list is not changed as the course is overfull. Now 7 rows. */

/* Test: Unregistered from an limited course with waiting list*/
"DELETE FROM registrations WHERE student = 3333333333 AND course = 'CCC333'
/* The registration is removed. 1111111111 is registered and the waiting list for CCC333 is now empty. Now 6 rows. */

/* Test: Unregistered from an limited course without waiting list*/
"DELETE FROM registrations WHERE student = 2222222222 AND course = 'CCC333'
/* The registration is removed. Now 5 rows. */


