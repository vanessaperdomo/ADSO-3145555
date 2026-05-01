package com.sena.test.DTO.BillDTO;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class PaymentDto {

    private UUID id;
    private BigDecimal amountPaid;
    private UUID invoiceId;
    private UUID methodPaymentId;
    private LocalDateTime paidAt;

    public PaymentDto() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public BigDecimal getAmountPaid() {
        return amountPaid;
    }

    public void setAmountPaid(BigDecimal amountPaid) {
        this.amountPaid = amountPaid;
    }

    public UUID getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(UUID invoiceId) {
        this.invoiceId = invoiceId;
    }

    public UUID getMethodPaymentId() {
        return methodPaymentId;
    }

    public void setMethodPaymentId(UUID methodPaymentId) {
        this.methodPaymentId = methodPaymentId;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }
}