ALTER TABLE credit_reservations DROP CONSTRAINT IF EXISTS ck_credit_reservations_amount;
ALTER TABLE credit_reservations
    ADD CONSTRAINT ck_credit_reservations_amount CHECK (amount_tc >= 0);
