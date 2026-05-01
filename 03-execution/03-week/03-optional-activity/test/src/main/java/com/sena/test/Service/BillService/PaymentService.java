package com.sena.test.Service.BillService;

import com.sena.test.DTO.BillDTO.PaymentDto;
import com.sena.test.Entity.Bill.Invoice;
import com.sena.test.Entity.Bill.MethodPayment;
import com.sena.test.Entity.Bill.Payment;
import com.sena.test.IRepository.IBillRepository.IInvoiceRepository;
import com.sena.test.IRepository.IBillRepository.IMethodPaymentRepository;
import com.sena.test.IRepository.IBillRepository.IPaymentRepository;
import com.sena.test.IService.IBillService.IPaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PaymentService implements IPaymentService {

    @Autowired
    private IPaymentRepository repository;

    @Autowired
    private IInvoiceRepository invoiceRepository;

    @Autowired
    private IMethodPaymentRepository methodPaymentRepository;

    private PaymentDto toDto(Payment e) {
        PaymentDto dto = new PaymentDto();
        dto.setId(e.getId());
        dto.setAmountPaid(e.getAmountPaid());
        dto.setInvoiceId(e.getInvoice().getId());
        dto.setMethodPaymentId(e.getMethodPayment().getId());
        dto.setPaidAt(e.getPaidAt());
        return dto;
    }

    private Payment toEntity(PaymentDto dto) {
        Payment e = new Payment();
        e.setAmountPaid(dto.getAmountPaid());
        Invoice invoice = invoiceRepository.findById(dto.getInvoiceId()).orElse(null);
        e.setInvoice(invoice);
        MethodPayment mp = methodPaymentRepository.findById(dto.getMethodPaymentId()).orElse(null);
        e.setMethodPayment(mp);
        return e;
    }

    @Override
    public List<PaymentDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public PaymentDto getById(UUID id) {
        Payment e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public PaymentDto create(PaymentDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}