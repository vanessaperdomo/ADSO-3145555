package com.sena.test.Service.BillService;

import com.sena.test.DTO.BillDTO.InvoiceDto;
import com.sena.test.Entity.Bill.Invoice;
import com.sena.test.Entity.Bill.Orders;
import com.sena.test.IRepository.IBillRepository.IInvoiceRepository;
import com.sena.test.IRepository.IBillRepository.IOrdersRepository;
import com.sena.test.IService.IBillService.IInvoiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class InvoiceService implements IInvoiceService {

    @Autowired
    private IInvoiceRepository repository;

    @Autowired
    private IOrdersRepository ordersRepository;

    private InvoiceDto toDto(Invoice e) {
        InvoiceDto dto = new InvoiceDto();
        dto.setId(e.getId());
        dto.setInvoiceNumber(e.getInvoiceNumber());
        dto.setTotal(e.getTotal());
        dto.setOrderId(e.getOrder().getId());
        dto.setCreatedAt(e.getCreatedAt());
        return dto;
    }

    private Invoice toEntity(InvoiceDto dto) {
        Invoice e = new Invoice();
        e.setInvoiceNumber(dto.getInvoiceNumber());
        e.setTotal(dto.getTotal());
        Orders order = ordersRepository.findById(dto.getOrderId()).orElse(null);
        e.setOrder(order);
        return e;
    }

    @Override
    public List<InvoiceDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public InvoiceDto getById(UUID id) {
        Invoice e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public InvoiceDto create(InvoiceDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public InvoiceDto update(UUID id, InvoiceDto dto) {
        Invoice e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setInvoiceNumber(dto.getInvoiceNumber());
        e.setTotal(dto.getTotal());
        Orders order = ordersRepository.findById(dto.getOrderId()).orElse(null);
        e.setOrder(order);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}