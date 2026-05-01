package com.sena.test.Controller.BillController;

import com.sena.test.DTO.BillDTO.MethodPaymentDto;
import com.sena.test.Service.BillService.MethodPaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/method-payment")
@CrossOrigin(origins = "*")
public class MethodPaymentController {

    @Autowired
    private MethodPaymentService methodPaymentService;

    @GetMapping
    public List<MethodPaymentDto> getAll() {
        return methodPaymentService.getAll();
    }

    @GetMapping("/{id}")
    public MethodPaymentDto getById(@PathVariable UUID id) {
        return methodPaymentService.getById(id);
    }

    @PostMapping
    public MethodPaymentDto create(@RequestBody MethodPaymentDto dto) {
        return methodPaymentService.create(dto);
    }

    @PutMapping("/{id}")
    public MethodPaymentDto update(@PathVariable UUID id, @RequestBody MethodPaymentDto dto) {
        return methodPaymentService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        methodPaymentService.delete(id);
        return "Eliminado exitosamente";
    }
}