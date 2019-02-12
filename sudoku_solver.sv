//==================================================================================================
//  Filename      : sudoku_solver.sv
//  Created On    : 2019-02-11 10:09:42
//  Last Modified : 2019-02-12 10:47:54
//  Revision      :
//  Author        : Gregory Arkaev
//  Email         : arkaev@live.ru
//
//  Description   :
//
//
//==================================================================================================
class sudoku_solver_base #(int M = 3); // M >= 1

  localparam N = M*M; //grid size

  rand  int unsigned box [N][N]; //box contain puzzle

`ifndef NOT_USE_UNIQUE
  typedef logic [N-1:0] int_t;

  local rand int_t [N-1:0] mesh [N-1:0];

  constraint box_to_mesh { foreach ( mesh[i,j] ) { mesh[i][j] == box[i][j]; } }
`endif

  // The value of each box must be between 1 and N.
  constraint box_con { foreach ( box[row, col] ) { box[row][col] inside { [1:N] }; } }

  // The boxes on the same column must have unique values.
`ifndef NOT_USE_UNIQUE
  constraint mesh_column_con { foreach (mesh[i,]) { unique {mesh[i]}; } }
`else
  constraint column_con {
    foreach   ( box[rowa, col] ) {
      foreach ( box[rowb,    ] ) {
        if ( rowa != rowb ) {
          box[rowa][col] != box[rowb][col];
        }
      }
    }
  }
`endif

  // The boxes on the same row must have unique values.
`ifndef NOT_USE_UNIQUE
  local rand int_t [N-1:0] mesh_trans [N-1:0];

  constraint mesh_to_meshtrans { foreach ( mesh_trans[i,j] ) { mesh_trans[i][j] == box[j][i]; } }

  constraint mesh_row_con { foreach (mesh_trans[i,]) { unique {mesh_trans[i]}; } }
`else
  constraint row_con {
    foreach   (box[row,cola]) {
      foreach (box[   ,colb]) {
          if (cola != colb) { box[row][cola] != box[row][colb]; }
      }
    }
  }
`endif

  // The boxes in the same MxM block must have unique values.
`ifndef NOT_USE_UNIQUE
  local rand int_t [N-1:0] mesh_block [N-1:0];

  constraint box_to_mesh_block { foreach ( mesh_block[i,j] ) { mesh_block[i][j] == box[(i/M)*M+j/M][(i%M)*M+j%M]; } }

  constraint mesh_block_con { foreach (mesh_block[i,]) { unique {mesh_block[i]}; } }
`else
  constraint block_con {
    foreach   ( box[rowa, cola] ) {
      foreach ( box[rowb, colb] ) {
        if ( rowa / M == rowb / M &&
             cola / M == colb / M &&
             ! ( rowa == rowb && cola == colb ) ) {
          box[rowa][cola] != box[rowb][colb];
        }
      }
    }
  }
`endif

  function void post_randomize();
    print();
  endfunction

  // Print the solution.
  function void print();

    string delim;

    $display("\n\n\n");

    delim = {M {{M{"---"}},"+"}};
    $display("%s", delim);

    for ( int i = 1; i <= N; i++ ) begin
      string line;

      for ( int j = 1; j <= N; j++ ) begin
        line = { line, $sformatf("%2d ", box[i-1][j-1]) };
        if (j%M == 0)
          line = {line, "|"};
      end

      $display("%s", line);

      if (i%M == 0)
        $display("%s", delim);

    end

    $display("\n\n\n");

  endfunction

endclass: sudoku_solver_base

// solve a specific puzzle
class sudoku_solver extends sudoku_solver_base;
  constraint puzzle_c {
    box[0][0] == 5;
    box[0][1] == 3;
    box[0][4] == 7;

    box[1][0] == 6;
    box[1][3] == 1;
    box[1][4] == 9;
    box[1][5] == 5;

    box[2][1] == 9;
    box[2][2] == 8;
    box[2][7] == 6;

    box[3][0] == 8;
    box[3][4] == 6;
    box[3][8] == 3;

    box[4][0] == 4;
    box[4][3] == 8;
    box[4][5] == 3;
    box[4][8] == 1;

    box[5][0] == 7;
    box[5][4] == 2;
    box[5][8] == 6;

    box[6][1] == 6;
    box[6][6] == 2;
    box[6][7] == 8;

    box[7][3] == 4;
    box[7][4] == 1;
    box[7][5] == 9;
    box[7][8] == 5;

    box[8][4] == 8;
    box[8][7] == 7;
    box[8][8] == 9;
  }
endclass

module top;

  int GRID_SIZE;

  sudoku_solver           solver  ;
  sudoku_solver_base #(3) solverx3;
  sudoku_solver_base #(4) solverx4;
  sudoku_solver_base #(5) solverx5;
  sudoku_solver_base #(6) solverx6;
  sudoku_solver_base #(7) solverx7;
  sudoku_solver_base #(8) solverx8;

  initial begin
    $value$plusargs("GRID_SIZE=%d", GRID_SIZE);

    case (GRID_SIZE)
      3:
      begin
        solverx3 = new();
        if (!solverx3.randomize())
          $fatal(1, "Could not solve!");
      end
      4:
      begin
        solverx4 = new();
        if (!solverx4.randomize())
          $fatal(1, "Could not solve!");
      end
      5:
      begin
        solverx5 = new();
        if (!solverx5.randomize())
          $fatal(1, "Could not solve!");
      end
      6:
      begin
        solverx6 = new();
        if (!solverx6.randomize())
          $fatal(1, "Could not solve!");
      end
      7:
      begin
        solverx7 = new();
        if (!solverx7.randomize())
          $fatal(1, "Could not solve!");
      end
      8:
      begin
        solverx8 = new();
        if (!solverx8.randomize())
          $fatal(1, "Could not solve!");
      end
      default:
      begin
        solver = new();
        if (!solver.randomize())
          $fatal(1, "Could not solve!");
      end
    endcase

    $finish();
  end
endmodule