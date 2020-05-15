use std::convert::TryFrom;

#[repr(u8)]
enum OpCode {
    Return = 0,
}

impl TryFrom<u8> for OpCode {
    type Error = &'static str;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            v if v == OpCode::Return as u8 => Ok(OpCode::Return),
            _ => Err("Unknown opcode"),
        }
    }
}

struct Chunk {
    name: &'static str,
    codes: Vec<u8>,
}

impl Chunk {
    pub fn new(name: &'static str) -> Self {
        Chunk {
            name,
            codes: vec![],
        }
    }

    pub fn init(name: &'static str, codes: Vec<u8>) -> Self {
        Chunk { name, codes }
    }

    pub fn write(&mut self, code: u8) {
        self.codes.push(code);
    }

    fn disassemble(&self) {
        println!("== {} ==", self.name);

        let mut offset = 0;
        while offset < self.codes.len() {
            offset = self.disassemble_instruction(offset);
        }
    }

    fn disassemble_instruction(&self, offset: usize) -> usize {
        print!("{:04} ", offset);

        let raw_code = self.codes[offset];
        match OpCode::try_from(raw_code) {
            Ok(code) => match code {
                OpCode::Return => {
                    println!("OP_RETURN");
                    offset + 1
                }
            },
            Err(msg) => {
                println!("{} {}", msg, raw_code);
                offset + 1
            }
        }
    }
}

mod tests {
    use super::*;

    #[test]
    fn chunk() {
        let mut chunk = Chunk::new("test");
        chunk.write(OpCode::Return as u8);
        chunk.disassemble();
    }
}
