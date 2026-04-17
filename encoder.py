mnemonic_program = []
with open('./program.txt', 'r') as f:
    for line in f:
        line = line.strip("\n")
        mnemonic_program.append(line)

mnemonic2opcode = {
        'add': '0000',
        'sub': '0001',
        'and': '0010',
        'or': '0011',
        'addi': '0100',
        'ld': '0101',
        'st': '0110',
        'beq': '0111',
        }

def encode_reg(reg):
    if reg == 0:
        return f'{0:03b}'
    else: 
        reg_num = int(reg[1:])
        return f'{reg_num:03b}'

def encode_opcode(op):
    return mnemonic2opcode[op.lower()]

def encode_imm(imm, bits=3):
    imm = int(imm)
    min_val = -(1 << (bits - 1))
    max_val = (1 << (bits - 1)) - 1
    if not (min_val <= imm <= max_val):
        raise ValueError(f"value [{imm}] out of range for {bits}-bit two's complement: {min_val}..{max_val}")
    unsigned = imm & ((1 << bits) - 1)
    return format(unsigned, f'0{bits}b')

def build_instruction(inst):
    instruction = ''
    match inst[0].lower():
        case ('add' | 'sub' | 'and' | 'or'):
            instruction += encode_opcode(inst[0])
            instruction += encode_reg(inst[1])
            instruction += encode_reg(inst[2])
            instruction += encode_reg(inst[3])
            instruction += encode_imm(0)
        case 'addi':
            instruction += encode_opcode(inst[0])
            instruction += encode_reg(inst[1])
            instruction += encode_reg(inst[2])
            instruction += encode_reg(0)
            instruction += encode_imm(inst[3])
        case 'ld':
            instruction += encode_opcode(inst[0])
            instruction += encode_reg(inst[1])
            instruction += encode_reg(inst[2])
            instruction += encode_reg(0)
            instruction += encode_imm(inst[3])
        case 'st':
            instruction += encode_opcode(inst[0])
            instruction += encode_reg(0)
            instruction += encode_reg(inst[2])
            instruction += encode_reg(inst[1])
            instruction += encode_imm(inst[3])
        case 'beq':
            instruction += encode_opcode(inst[0])
            instruction += encode_reg(0)
            instruction += encode_reg(inst[1])
            instruction += encode_reg(inst[2])
            instruction += encode_imm(inst[3])
        case _:
            exit('unknown opcode')
    return instruction

def bin2hex(b):
    return format(int(b,2), "04x")

print(f"\n========program printout========\n")

hex_program = []
for inst in mnemonic_program:
    i = inst.split(' ')
    i = [s.strip(',[]+') for s in i]
    i = list(filter(None, i))
    b_i = build_instruction(i)
    h_i = bin2hex(b_i)
    hex_program.append(h_i)
    print(f'{inst} => {b_i} => {h_i}')

print(f"\n========copy/paste below========\n")

for i, inst in enumerate(hex_program):
    print(f'    IMEM({i}) <= x"{inst}"; -- {mnemonic_program[i]}')
