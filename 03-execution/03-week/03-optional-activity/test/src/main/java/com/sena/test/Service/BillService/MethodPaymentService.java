package com.sena.test.Service.BillService;

import com.sena.test.DTO.BillDTO.MethodPaymentDto;
import com.sena.test.Entity.Bill.MethodPayment;
import com.sena.test.IRepository.IBillRepository.IMethodPaymentRepository;
import com.sena.test.IService.IBillService.IMethodPaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MethodPaymentService implements IMethodPaymentService {

    @Autowired
    private IMethodPaymentRepository repository;

    private MethodPaymentDto toDto(MethodPayment e) {
        MethodPaymentDto dto = new MethodPaymentDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    private MethodPayment toEntity(MethodPaymentDto dto) {
        MethodPayment e = new MethodPayment();
        e.setName(dto.getName());
        return e;
    }

    @Override
    public List<MethodPaymentDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public MethodPaymentDto getById(UUID id) {
        MethodPayment e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public MethodPaymentDto create(MethodPaymentDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public MethodPaymentDto update(UUID id, MethodPaymentDto dto) {
        MethodPayment e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setName(dto.getName());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}