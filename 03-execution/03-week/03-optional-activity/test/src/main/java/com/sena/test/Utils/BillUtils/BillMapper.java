package com.sena.test.Utils.BillUtils;

import com.sena.test.DTO.BillDTO.*;
import com.sena.test.Entity.Bill.*;

public class BillMapper {

    // ── OrderStatus ──────────────────────────────────────────
    public static OrderStatusDto toDto(OrderStatus e) {
        OrderStatusDto dto = new OrderStatusDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    public static OrderStatus toEntity(OrderStatusDto dto) {
        OrderStatus e = new OrderStatus();
        e.setName(dto.getName());
        return e;
    }

    // ── Orders ───────────────────────────────────────────────
    public static OrdersDto toDto(Orders e) {
        OrdersDto dto = new OrdersDto();
        dto.setId(e.getId());
        dto.setTotalAmount(e.getTotalAmount());
        dto.setStatusId(e.getStatus().getId());
        dto.setCustomerId(e.getCustomer().getId());
        dto.setCreatedAt(e.getCreatedAt());
        return dto;
    }

    // ── OrderItem ────────────────────────────────────────────
    public static OrderItemDto toDto(OrderItem e) {
        OrderItemDto dto = new OrderItemDto();
        dto.setId(e.getId());
        dto.setOrderId(e.getOrder().getId());
        dto.setProductId(e.getProduct().getId());
        dto.setQuantity(e.getQuantity());
        dto.setUnitPrice(e.getUnitPrice());
        return dto;
    }

    // ── Invoice ──────────────────────────────────────────────
    public static InvoiceDto toDto(Invoice e) {
        InvoiceDto dto = new InvoiceDto();
        dto.setId(e.getId());
        dto.setInvoiceNumber(e.getInvoiceNumber());
        dto.setTotal(e.getTotal());
        dto.setOrderId(e.getOrder().getId());
        dto.setCreatedAt(e.getCreatedAt());
        return dto;
    }

    // ── InvoiceItem ──────────────────────────────────────────
    public static InvoiceItemDto toDto(InvoiceItem e) {
        InvoiceItemDto dto = new InvoiceItemDto();
        dto.setId(e.getId());
        dto.setInvoiceId(e.getInvoice().getId());
        dto.setProductId(e.getProduct().getId());
        dto.setQuantity(e.getQuantity());
        dto.setPrice(e.getPrice());
        return dto;
    }

    // ── MethodPayment ────────────────────────────────────────
    public static MethodPaymentDto toDto(MethodPayment e) {
        MethodPaymentDto dto = new MethodPaymentDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    public static MethodPayment toEntity(MethodPaymentDto dto) {
        MethodPayment e = new MethodPayment();
        e.setName(dto.getName());
        return e;
    }

    // ── Payment ──────────────────────────────────────────────
    public static PaymentDto toDto(Payment e) {
        PaymentDto dto = new PaymentDto();
        dto.setId(e.getId());
        dto.setAmountPaid(e.getAmountPaid());
        dto.setInvoiceId(e.getInvoice().getId());
        dto.setMethodPaymentId(e.getMethodPayment().getId());
        dto.setPaidAt(e.getPaidAt());
        return dto;
    }
}